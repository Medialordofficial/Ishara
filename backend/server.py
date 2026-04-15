from __future__ import annotations

"""
Ishara Backend Server
FastAPI bridge between the Flutter app and Gemma 4 via Ollama.
"""

import base64
import json
import logging
import os
import time
from collections import defaultdict
from contextlib import asynccontextmanager

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("ishara")

import httpx
from fastapi import FastAPI, File, Form, HTTPException, Request, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434")
MODEL = os.getenv("ISHARA_MODEL", "gemma4")


# ─── Response Models ───────────────────────────────────────

class PingResponse(BaseModel):
    status: str
    model: str

class HealthResponse(BaseModel):
    status: str
    ollama: bool
    model: str

class SignResponse(BaseModel):
    sign: str
    confidence: float = Field(default=0.0, ge=0.0, le=1.0)

class SpeechToTextResponse(BaseModel):
    text: str
    available: bool

class SoundClassification(BaseModel):
    sound: str
    level: str = "info"
    description: str = ""

class EmergencyMessageResponse(BaseModel):
    message: str

class ChatResponse(BaseModel):
    reply: str

class WorldReaderResponse(BaseModel):
    description: str

class EvaluateSignResponse(BaseModel):
    feedback: str


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Verify Ollama connection on startup."""
    try:
        async with httpx.AsyncClient() as client:
            r = await client.get(f"{OLLAMA_URL}/api/tags", timeout=5)
            models = [m["name"] for m in r.json().get("models", [])]
            if any(MODEL in m for m in models):
                logger.info("Ollama connected — %s ready", MODEL)
            else:
                logger.warning("Ollama connected but %s not found. Run: ollama pull %s", MODEL, MODEL)
    except Exception:
        logger.warning("Could not reach Ollama at %s. Start it with: ollama serve", OLLAMA_URL)
    yield


app = FastAPI(title="Ishara API", version="1.0.0", lifespan=lifespan)

ALLOWED_ORIGINS = os.getenv("ISHARA_CORS_ORIGINS", "*").split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type", "X-API-Key"],
)

MAX_IMAGE_BYTES = 10 * 1024 * 1024  # 10 MB
ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp", "image/gif"}
ALLOWED_EMERGENCY_TYPES = {"medical", "police", "fire", "natural_disaster", "other"}
MAX_TEXT_LENGTH = 2000
RATE_LIMIT_WINDOW = 60  # seconds
RATE_LIMIT_MAX = int(os.getenv("ISHARA_RATE_LIMIT", "30"))  # requests per window
API_KEY = os.getenv("ISHARA_API_KEY", "")  # Set to enable auth


# ─── Authentication ────────────────────────────────────────

EXEMPT_PATHS = {"/ping", "/health", "/docs", "/openapi.json", "/redoc"}


@app.middleware("http")
async def auth_middleware(request: Request, call_next):
    """Validate API key when ISHARA_API_KEY is set."""
    if API_KEY and request.url.path not in EXEMPT_PATHS:
        provided = request.headers.get("x-api-key", "")
        if provided != API_KEY:
            client_ip = request.client.host if request.client else "unknown"
            logger.warning("AUTH_FAIL ip=%s path=%s", client_ip, request.url.path)
            return JSONResponse(
                status_code=401,
                content={"detail": "Invalid or missing API key"},
            )
    return await call_next(request)


# ─── Rate Limiting ─────────────────────────────────────────

_rate_store: dict[str, list[float]] = defaultdict(list)
# WARNING: In-memory store only. Not safe for multi-worker deployments.
# For production with multiple uvicorn workers, use Redis:
#   pip install redis; store = redis.Redis(); store.expire(...)


@app.middleware("http")
async def rate_limit_middleware(request: Request, call_next):
    """Simple in-memory per-IP rate limiter."""
    if request.url.path in EXEMPT_PATHS:
        return await call_next(request)

    client_ip = request.client.host if request.client else "unknown"
    now = time.monotonic()
    window_start = now - RATE_LIMIT_WINDOW

    # Prune old entries
    _rate_store[client_ip] = [t for t in _rate_store[client_ip] if t > window_start]

    if len(_rate_store[client_ip]) >= RATE_LIMIT_MAX:
        logger.warning("RATE_LIMIT ip=%s path=%s", client_ip, request.url.path)
        return JSONResponse(
            status_code=429,
            content={"detail": "Rate limit exceeded. Try again later."},
        )

    _rate_store[client_ip].append(now)
    response = await call_next(request)
    # Audit log for non-health endpoints
    if request.url.path not in EXEMPT_PATHS:
        logger.info(
            "REQUEST ip=%s method=%s path=%s status=%d",
            client_ip, request.method, request.url.path, response.status_code,
        )
    return response


# ─── Helpers ───────────────────────────────────────────────


def _sanitize_user_input(text: str) -> str:
    """Strip common prompt-injection patterns from user text.

    This is a best-effort defence; the primary safeguard is that Gemma 4
    runs locally so the blast radius is limited to degraded quality.
    """
    # Remove attempts to override system prompt
    import re

    # Strip common injection prefixes
    patterns = [
        r"(?i)^(system|assistant|instruction|prompt)\s*:",
        r"(?i)ignore\s+(all\s+)?(previous|above|prior)\s+(instructions|prompts|rules)",
        r"(?i)you\s+are\s+now\s+(a|an|in)\s+",
        r"(?i)forget\s+(everything|all|your\s+instructions)",
    ]
    sanitized = text
    for pat in patterns:
        sanitized = re.sub(pat, "[filtered]", sanitized)
    return sanitized.strip()


async def _chat(prompt: str, image_b64: str | None = None) -> str:
    """Send a prompt (optionally with an image) to Gemma 4 via Ollama."""
    payload: dict = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False,
    }
    if image_b64:
        payload["images"] = [image_b64]

    try:
        async with httpx.AsyncClient(timeout=httpx.Timeout(300, connect=10)) as client:
            r = await client.post(f"{OLLAMA_URL}/api/generate", json=payload)
            r.raise_for_status()
            return r.json().get("response", "")
    except httpx.ConnectError as exc:
        raise HTTPException(status_code=503, detail="Cannot reach Ollama. Is it running?") from exc
    except httpx.TimeoutException as exc:
        raise HTTPException(status_code=504, detail="Ollama request timed out") from exc
    except httpx.HTTPStatusError as exc:
        raise HTTPException(status_code=502, detail=f"Ollama returned error: {exc.response.status_code}") from exc


async def _read_upload(upload: UploadFile) -> str:
    """Read an uploaded image and return base64 with size & type validation."""
    if upload.content_type and upload.content_type not in ALLOWED_IMAGE_TYPES:
        raise HTTPException(status_code=400, detail=f"Unsupported image type: {upload.content_type}")
    data = await upload.read()
    if len(data) > MAX_IMAGE_BYTES:
        raise HTTPException(status_code=413, detail=f"Image too large: {len(data)} bytes (max {MAX_IMAGE_BYTES})")
    return base64.b64encode(data).decode("utf-8")


# ─── Endpoints ─────────────────────────────────────────────

@app.get("/ping", response_model=PingResponse)
async def ping():
    return PingResponse(status="ok", model=MODEL)


# 1. Conversation Mode — interpret sign language from camera frame
@app.post("/interpret-sign", response_model=SignResponse)
async def interpret_sign(image: UploadFile = File(...)):
    b64 = await _read_upload(image)
    prompt = (
        "You are an expert sign language interpreter. "
        "Look at this image of a person making a sign language gesture. "
        "Identify the sign being made and translate it into English. "
        "If no clear sign is visible, say 'No sign detected'. "
        "Reply with ONLY a JSON object like: {\"sign\": \"Hello\", \"confidence\": 0.85} "
        "where confidence is your certainty from 0.0 to 1.0."
    )
    raw = await _chat(prompt, b64)
    sign = raw.strip()
    confidence = 0.0
    try:
        import json as _json
        start = raw.find("{")
        end = raw.rfind("}") + 1
        if start >= 0 and end > start:
            parsed = _json.loads(raw[start:end])
            sign = str(parsed.get("sign", raw.strip()))
            confidence = float(parsed.get("confidence", 0.0))
    except (ValueError, KeyError):
        pass
    return SignResponse(sign=sign, confidence=confidence)


# 1b. Conversation Mode — speech-to-text (placeholder; real STT via Whisper later)
class SpeechRequest(BaseModel):
    audio_b64: str

@app.post("/speech-to-text", response_model=SpeechToTextResponse)
async def speech_to_text(_req: SpeechRequest):
    # On-device STT via Flutter speech_to_text package is the primary path.
    # This endpoint is reserved for server-side Whisper integration.
    return SpeechToTextResponse(
        text="[Server STT not yet available \u2014 use on-device speech_to_text]",
        available=False,
    )


# 2. Sound Awareness — classify an audio description
class SoundRequest(BaseModel):
    description: str

@app.post("/classify-sound", response_model=SoundClassification)
async def classify_sound(req: SoundRequest):
    safe_desc = _sanitize_user_input(req.description)
    prompt = (
        "You are helping a deaf person understand sounds around them. "
        f"The microphone detected this sound: '{safe_desc}'. "
        "Classify it as one of: doorbell, alarm, car_horn, dog_bark, "
        "baby_cry, siren, speech, appliance, music, knock, other. "
        "Also rate urgency: critical, warning, or info. "
        "Reply in JSON: {\"sound\": \"...\", \"level\": \"...\", \"description\": \"...\"}"
    )
    raw = await _chat(prompt)
    try:
        # Try to parse JSON from the response
        start = raw.find("{")
        end = raw.rfind("}") + 1
        if start >= 0 and end > start:
            data = json.loads(raw[start:end])
            return SoundClassification(
                sound=data.get("sound", "unknown"),
                level=data.get("level", "info"),
                description=data.get("description", ""),
            )
    except (json.JSONDecodeError, ValueError):
        pass
    return SoundClassification(sound="unknown", level="info", description=raw.strip())


# 3. Emergency SOS — generate emergency message
class EmergencyRequest(BaseModel):
    emergency_type: str
    latitude: float = 0.0
    longitude: float = 0.0

@app.post("/emergency-message", response_model=EmergencyMessageResponse)
async def emergency_message(req: EmergencyRequest):
    if req.emergency_type.lower() not in ALLOWED_EMERGENCY_TYPES:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid emergency_type. Allowed: {', '.join(sorted(ALLOWED_EMERGENCY_TYPES))}",
        )
    prompt = (
        f"Generate a brief, clear emergency message for a {req.emergency_type} emergency. "
        "The sender is a deaf person who cannot make voice calls. "
        f"Location coordinates: {req.latitude}, {req.longitude}. "
        "Include: type of emergency, request for help, note that the person is deaf "
        "and communicates via text. Keep it under 3 sentences."
    )
    result = await _chat(prompt)
    return EmergencyMessageResponse(message=result.strip())


# 3b. Emergency — operator chat
class ChatRequest(BaseModel):
    message: str
    context: str = ""

@app.post("/emergency-chat", response_model=ChatResponse)
async def emergency_chat(req: ChatRequest):
    if len(req.message) > MAX_TEXT_LENGTH:
        raise HTTPException(status_code=400, detail=f"Message too long (max {MAX_TEXT_LENGTH} chars)")
    safe_msg = _sanitize_user_input(req.message)
    safe_ctx = _sanitize_user_input(req.context)
    prompt = (
        "You are simulating an emergency dispatcher responding to a deaf person's text. "
        "Be calm, clear, and helpful. Use simple language. "
        f"Context: {safe_ctx}\n"
        f"Their message: {safe_msg}\n"
        "Your response (keep it short and actionable):"
    )
    result = await _chat(prompt)
    return ChatResponse(reply=result.strip())


# 4. World Reader — read and describe what the camera sees
@app.post("/read-world", response_model=WorldReaderResponse)
async def read_world(
    image: UploadFile = File(...),
    question: str = Form(""),
):
    b64 = await _read_upload(image)
    safe_question = _sanitize_user_input(question) if question.strip() else ""
    if safe_question:
        prompt = (
            "You are helping a deaf person understand their surroundings. "
            "Look at this image and answer their question clearly and simply. "
            f"Their question: {safe_question}"
        )
    else:
        prompt = (
            "You are helping a deaf person understand their surroundings. "
            "Describe what you see in this image. Focus on: "
            "1) Any text (signs, labels, menus) — read it out fully. "
            "2) Important objects or people. "
            "3) Any safety-relevant information. "
            "Keep the description clear and concise."
        )
    result = await _chat(prompt, b64)
    return WorldReaderResponse(description=result.strip())


# 5. Learn Signs — evaluate a user's sign attempt
@app.post("/evaluate-sign", response_model=EvaluateSignResponse)
async def evaluate_sign(
    image: UploadFile = File(...),
    target_sign: str = Form(...),
):
    b64 = await _read_upload(image)
    prompt = (
        f"You are a sign language teacher. The student is trying to sign '{target_sign}'. "
        "Look at this image and evaluate their hand position and gesture. "
        "Give brief, encouraging feedback: what they did well and what to adjust. "
        "If you can't clearly see the sign, ask them to try again with better lighting. "
        "Keep feedback to 2-3 sentences."
    )
    result = await _chat(prompt, b64)
    return EvaluateSignResponse(feedback=result.strip())


# 6. General Chat — LLM conversation for accessibility assistance
class GeneralChatRequest(BaseModel):
    message: str
    history: list[dict] = []

@app.post("/chat", response_model=ChatResponse)
async def general_chat(req: GeneralChatRequest):
    if len(req.message) > MAX_TEXT_LENGTH:
        raise HTTPException(status_code=400, detail=f"Message too long (max {MAX_TEXT_LENGTH} chars)")
    safe_msg = _sanitize_user_input(req.message)
    context = ""
    if req.history:
        context = "\n".join(
            f"{h.get('role', 'user')}: {_sanitize_user_input(h.get('content', ''))}"
            for h in req.history[-6:]  # Last 6 messages for context
        )
    prompt = (
        "You are Ishara AI, a helpful assistant for deaf and hard-of-hearing people. "
        "You help with sign language questions, accessibility tips, and general conversation. "
        "Keep responses clear, concise, and supportive.\n"
    )
    if context:
        prompt += f"\nRecent conversation:\n{context}\n"
    prompt += f"\nUser: {safe_msg}\nAssistant:"
    result = await _chat(prompt)
    return ChatResponse(reply=result.strip())


@app.get("/health", response_model=HealthResponse)
async def health():
    """Health check for monitoring and CI."""
    try:
        async with httpx.AsyncClient() as client:
            r = await client.get(f"{OLLAMA_URL}/api/tags", timeout=3)
            ollama_ok = r.status_code == 200
    except Exception:
        ollama_ok = False
    return HealthResponse(status="ok", ollama=ollama_ok, model=MODEL)


# ─── User Feedback ─────────────────────────────────────────

class FeedbackResponse(BaseModel):
    received: bool

class FeedbackRequest(BaseModel):
    interpreted_sign: str = Field(max_length=200)
    correct_sign: str = Field(max_length=200)
    context: str = Field(default="", max_length=500)

@app.post("/feedback", response_model=FeedbackResponse)
async def feedback(req: FeedbackRequest):
    """Log user correction for sign interpretation.

    Enables continuous improvement: collect (interpreted, correct) pairs
    and use them to build a fine-tuning dataset.
    """
    logger.info(
        "FEEDBACK interpreted=%s correct=%s",
        _sanitize_user_input(req.interpreted_sign),
        _sanitize_user_input(req.correct_sign),
    )
    return FeedbackResponse(received=True)


if __name__ == "__main__":
    import uvicorn
    logger.info("Starting Ishara backend on port 8000...")
    uvicorn.run(app, host="0.0.0.0", port=8000)
