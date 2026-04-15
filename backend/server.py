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
from pydantic import BaseModel

OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434")
MODEL = os.getenv("ISHARA_MODEL", "gemma4")


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
    allow_headers=["Content-Type"],
)

MAX_IMAGE_BYTES = 10 * 1024 * 1024  # 10 MB
ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp", "image/gif"}
ALLOWED_EMERGENCY_TYPES = {"medical", "police", "fire", "natural_disaster", "other"}
MAX_TEXT_LENGTH = 2000
RATE_LIMIT_WINDOW = 60  # seconds
RATE_LIMIT_MAX = int(os.getenv("ISHARA_RATE_LIMIT", "30"))  # requests per window


# ─── Rate Limiting ─────────────────────────────────────────

_rate_store: dict[str, list[float]] = defaultdict(list)


@app.middleware("http")
async def rate_limit_middleware(request: Request, call_next):
    """Simple in-memory per-IP rate limiter."""
    if request.url.path in ("/ping", "/health", "/docs", "/openapi.json"):
        return await call_next(request)

    client_ip = request.client.host if request.client else "unknown"
    now = time.monotonic()
    window_start = now - RATE_LIMIT_WINDOW

    # Prune old entries
    _rate_store[client_ip] = [t for t in _rate_store[client_ip] if t > window_start]

    if len(_rate_store[client_ip]) >= RATE_LIMIT_MAX:
        return JSONResponse(
            status_code=429,
            content={"detail": "Rate limit exceeded. Try again later."},
        )

    _rate_store[client_ip].append(now)
    return await call_next(request)


# ─── Helpers ───────────────────────────────────────────────

async def _chat(prompt: str, image_b64: str | None = None) -> str:
    """Send a prompt (optionally with an image) to Gemma 4 via Ollama."""
    payload: dict = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False,
    }
    if image_b64:
        payload["images"] = [image_b64]

    async with httpx.AsyncClient(timeout=httpx.Timeout(300, connect=10)) as client:
        r = await client.post(f"{OLLAMA_URL}/api/generate", json=payload)
        r.raise_for_status()
        return r.json().get("response", "")


async def _read_upload(upload: UploadFile) -> str:
    """Read an uploaded image and return base64 with size & type validation."""
    if upload.content_type and upload.content_type not in ALLOWED_IMAGE_TYPES:
        raise HTTPException(status_code=400, detail=f"Unsupported image type: {upload.content_type}")
    data = await upload.read()
    if len(data) > MAX_IMAGE_BYTES:
        raise HTTPException(status_code=413, detail=f"Image too large: {len(data)} bytes (max {MAX_IMAGE_BYTES})")
    return base64.b64encode(data).decode("utf-8")


# ─── Endpoints ─────────────────────────────────────────────

@app.get("/ping")
async def ping():
    return {"status": "ok", "model": MODEL}


# 1. Conversation Mode — interpret sign language from camera frame
@app.post("/interpret-sign")
async def interpret_sign(image: UploadFile = File(...)):
    b64 = await _read_upload(image)
    prompt = (
        "You are an expert sign language interpreter. "
        "Look at this image of a person making a sign language gesture. "
        "Identify the sign being made and translate it into English. "
        "If no clear sign is visible, say 'No sign detected'. "
        "Reply with ONLY the translated word or short phrase, nothing else."
    )
    result = await _chat(prompt, b64)
    return {"sign": result.strip()}


# 1b. Conversation Mode — speech-to-text (placeholder; real STT via Whisper later)
class SpeechRequest(BaseModel):
    audio_b64: str

@app.post("/speech-to-text")
async def speech_to_text(_req: SpeechRequest):
    # On-device STT via Flutter speech_to_text package is the primary path.
    # This endpoint is reserved for server-side Whisper integration.
    return {"text": "[Server STT not yet available — use on-device speech_to_text]", "available": False}


# 2. Sound Awareness — classify an audio description
class SoundRequest(BaseModel):
    description: str

@app.post("/classify-sound")
async def classify_sound(req: SoundRequest):
    prompt = (
        "You are helping a deaf person understand sounds around them. "
        f"The microphone detected this sound: '{req.description}'. "
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
            return data
    except (json.JSONDecodeError, ValueError):
        pass
    return {"sound": "unknown", "level": "info", "description": raw.strip()}


# 3. Emergency SOS — generate emergency message
class EmergencyRequest(BaseModel):
    emergency_type: str
    latitude: float = 0.0
    longitude: float = 0.0

@app.post("/emergency-message")
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
    return {"message": result.strip()}


# 3b. Emergency — operator chat
class ChatRequest(BaseModel):
    message: str
    context: str = ""

@app.post("/emergency-chat")
async def emergency_chat(req: ChatRequest):
    if len(req.message) > MAX_TEXT_LENGTH:
        raise HTTPException(status_code=400, detail=f"Message too long (max {MAX_TEXT_LENGTH} chars)")
    prompt = (
        "You are simulating an emergency dispatcher responding to a deaf person's text. "
        "Be calm, clear, and helpful. Use simple language. "
        f"Context: {req.context}\n"
        f"Their message: {req.message}\n"
        "Your response (keep it short and actionable):"
    )
    result = await _chat(prompt)
    return {"reply": result.strip()}


# 4. World Reader — read and describe what the camera sees
@app.post("/read-world")
async def read_world(
    image: UploadFile = File(...),
    question: str = Form(""),
):
    b64 = await _read_upload(image)
    if question.strip():
        prompt = (
            "You are helping a deaf person understand their surroundings. "
            "Look at this image and answer their question clearly and simply. "
            f"Their question: {question}"
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
    return {"description": result.strip()}


# 5. Learn Signs — evaluate a user's sign attempt
@app.post("/evaluate-sign")
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
    return {"feedback": result.strip()}


# 6. General Chat — LLM conversation for accessibility assistance
class GeneralChatRequest(BaseModel):
    message: str
    history: list[dict] = []

@app.post("/chat")
async def general_chat(req: GeneralChatRequest):
    if len(req.message) > MAX_TEXT_LENGTH:
        raise HTTPException(status_code=400, detail=f"Message too long (max {MAX_TEXT_LENGTH} chars)")
    context = ""
    if req.history:
        context = "\n".join(
            f"{h.get('role', 'user')}: {h.get('content', '')}"
            for h in req.history[-6:]  # Last 6 messages for context
        )
    prompt = (
        "You are Ishara AI, a helpful assistant for deaf and hard-of-hearing people. "
        "You help with sign language questions, accessibility tips, and general conversation. "
        "Keep responses clear, concise, and supportive.\n"
    )
    if context:
        prompt += f"\nRecent conversation:\n{context}\n"
    prompt += f"\nUser: {req.message}\nAssistant:"
    result = await _chat(prompt)
    return {"reply": result.strip()}


@app.get("/health")
async def health():
    """Health check for monitoring and CI."""
    try:
        async with httpx.AsyncClient() as client:
            r = await client.get(f"{OLLAMA_URL}/api/tags", timeout=3)
            ollama_ok = r.status_code == 200
    except Exception:
        ollama_ok = False
    return {"status": "ok", "ollama": ollama_ok, "model": MODEL}


if __name__ == "__main__":
    import uvicorn
    logger.info("Starting Ishara backend on port 8000...")
    uvicorn.run(app, host="0.0.0.0", port=8000)
