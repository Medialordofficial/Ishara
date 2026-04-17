# Ishara: AI-Powered Accessibility Companion for the Deaf Community

**Subtitle:** Using Gemma 4's multimodal vision, native function calling, and intelligent model routing to break communication barriers for 430 million deaf and hard-of-hearing people worldwide.

**Track:** Digital Equity & Inclusivity | Ollama Special Tech Track

---

## The Problem

There are 430 million people worldwide with disabling hearing loss. Every day they face a wall of silent emergencies: a fire alarm they cannot hear, a pharmacist they cannot communicate with, a world full of written text they cannot ask questions about.

Existing tools are fragmented — a speech-to-text app here, an emergency button there, a basic sign language dictionary somewhere else. None of them are connected. None of them use AI intelligently. And none of them run without handing your most sensitive health and safety data to a cloud provider you cannot audit.

**Ishara** (Swahili and Arabic for *"sign"* or *"gesture"*) is the unified answer.

---

## The Solution

Ishara is a complete, offline-capable Android accessibility companion with five deeply integrated AI modes — all powered by **Gemma 4 running locally via Ollama**. No cloud dependency. No data leaving the local network. Everything private, fast, and accessible.

### Five Modes, One App

**1. Conversation Mode** — Sign language interpreter in your pocket. The user points their phone camera at themselves and signs. Google ML Kit Pose Detection (33 landmarks, fully on-device) acts as a smart gate: it only triggers a Gemma 4 multimodal inference call when a signing posture is actually detected — hands raised, correct arm angles, face in frame. This eliminates ~70% of unnecessary AI calls and dramatically improves battery life. Gemma 4 receives the frame and returns the interpreted sign, which is spoken aloud via Text-to-Speech.

**2. Sound Awareness** — Always-on background microphone monitoring converts ambient sound descriptions into typed alerts. This is where we use **Gemma 4's native function calling** — rather than asking the model to emit raw JSON (which is fragile), we define a typed `classify_ambient_sound` tool schema. Gemma 4 invokes the tool directly, returning a strongly-typed `{sound, level, description}` struct. The result: reliable classification into 11 categories (siren, alarm, doorbell, speech...) with urgency tiers (critical / warning / info), rendered as color-coded haptic alerts on screen.

**3. Emergency SOS** — One-tap emergency dispatch for deaf users who cannot make voice calls. Gemma 4 generates a clear, location-aware emergency message in under 2 seconds: *"EMERGENCY: Medical situation. The sender is deaf and cannot make voice calls. GPS: 1.2345°N, 4.5678°E. Please send help immediately."* The message is shown on screen, sent via SMS, and the phone calls emergency services — all simultaneously.

**4. World Reader** — Point the camera, ask a question. Gemma 4's multimodal vision reads text from menus, signs, prescription labels, street signs, and whiteboards — and answers the user's specific question about what it sees. Pharmacy instructions. Transport timetables. Restaurant menus. All read aloud.

**5. Learn Signs** — AI-coached sign language practice with 170+ signs across 15 difficulty-tiered categories. The user attempts a sign, Gemma 4 evaluates the image and gives 2-3 sentences of encouraging feedback on hand position and gesture accuracy. Progress is tracked with streaks and difficulty unlocks.

---

## Gemma 4 Technical Architecture

### Intelligent Model Routing

Gemma 4 ships in multiple weight classes — from the nimble E2B/E4B edge variants to the powerful 26B/31B full models. Ishara exploits this with **intelligent two-tier routing**:

```
FAST_MODEL (e.g. gemma4:4b)  → Text-only tasks: sound classification, chat, 
                                emergency operator simulation
FULL_MODEL (e.g. gemma4:27b) → Multimodal + safety-critical: sign interpretation, 
                                world reading, sign evaluation, emergency message
```

Both tiers are configurable via environment variables (`ISHARA_FAST_MODEL`, `ISHARA_FULL_MODEL`) and default to the same model if only one Gemma 4 variant is available. The routing happens transparently inside the `_chat()` function — a single `model` parameter selects the weight class per call.

### Native Function Calling

Gemma 4 introduced native function/tool calling — a capability absent from earlier Gemma generations. We use it for the Sound Awareness classifier:

```json
{
  "type": "function",
  "function": {
    "name": "classify_ambient_sound",
    "parameters": {
      "properties": {
        "sound":       { "type": "string", "enum": ["siren","alarm","doorbell",...] },
        "level":       { "type": "string", "enum": ["critical","warning","info"] },
        "description": { "type": "string" }
      }
    }
  }
}
```

Gemma 4 fills this schema directly — no JSON parsing, no regex extraction, no format hallucinations. The fallback path (JSON-parse from a text prompt) is still present for model versions that don't trigger tool calls, so the app degrades gracefully.

### Multimodal Vision Pipeline

All three camera-based modes (Conversation, World Reader, Learn Signs) use Gemma 4's native multimodal understanding. Frames are base64-encoded and posted to Ollama's `/api/generate` endpoint with an image array. The prompt is carefully engineered per mode:

- **Sign interpretation**: Expert few-shot examples of five common signs to anchor the model's output format
- **World reading**: Structured output prompt prioritising text extraction, then objects, then safety information
- **Sign evaluation**: Teacher persona with explicit encouragement framing to produce kind, actionable feedback

### Local-First Privacy Architecture

```
Phone ──(WiFi)──► FastAPI Server ──► Ollama ──► Gemma 4 (local weights)
                        ↑
              No outbound internet calls
              No telemetry
              No cloud API keys
```

The FastAPI bridge includes a circuit breaker (fails fast when Ollama is unreachable), per-IP rate limiting, API key authentication, and prompt injection sanitisation — production-grade security for a local-first system.

---

## Technical Depth

### Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter 3.38.5 / Dart 3.10.4 |
| On-Device ML | Google ML Kit Pose Detection (33 landmarks) |
| AI Model | Gemma 4 via Ollama (local inference) |
| Backend Bridge | FastAPI + httpx (async, circuit breaker) |
| Model Routing | `FAST_MODEL` / `FULL_MODEL` env-var split |
| Function Calling | Gemma 4 native tool schema (`_chat_with_tools`) |

### Test Coverage

- **259 Flutter unit/widget/integration tests** covering all 5 modes
- **93 backend tests** (including 10 new tests specifically for function calling and model routing)
- CI/CD pipeline via GitHub Actions

### Key Engineering Decisions

1. **ML Kit pose gating** avoids saturating the Gemma 4 server with blurry or non-signing frames. Only frames meeting the signing confidence threshold (configurable) are forwarded. This is the key insight that makes real-time sign interpretation feel responsive.

2. **Circuit breaker pattern** in the FastAPI bridge means the Flutter app gets an immediate "AI offline" message after 3 consecutive Ollama failures — rather than waiting 30s × 2 retries every time.

3. **Gemma 4 function calling for structured outputs** is fundamentally more reliable than asking the model to emit JSON. The tool schema acts as a grammar constraint — the model fills a typed struct rather than inventing its own format.

4. **Two-tier model routing** separates latency-sensitive text tasks (chat, sound classification) from accuracy-sensitive multimodal tasks. A user chatting about ASL gets a near-instant response from the fast model. A user reading a prescription gets the full model's attention.

---

## Real-World Impact

Ishara directly addresses three UN Sustainable Development Goals:
- **SDG 3** (Good Health): Emergency SOS keeps deaf people safe in medical crises
- **SDG 4** (Quality Education): Learn Signs mode provides AI coaching for accessible language learning
- **SDG 10** (Reduced Inequalities): Conversation Mode removes the communication barrier between deaf and hearing people in real time

The app is fully offline-capable for the core AI features once the Gemma 4 model is pulled to the local machine — making it viable in low-connectivity environments where cloud-dependent tools fail.

---

## What Makes This a Strong Gemma 4 Use Case

Most accessibility apps rely on cloud APIs. Ishara deliberately inverts this: the local-first design is not a limitation — it is the feature. Deaf users share some of the most sensitive information imaginable through an accessibility app: their GPS location during emergencies, medical images of their prescriptions, live video of themselves signing. **Gemma 4's ability to run the full model stack locally is what makes Ishara ethically deployable.**

We use four distinct Gemma 4 capabilities that distinguish it from previous Gemma generations:
1. **Multimodal vision** — the backbone of three out of five modes
2. **Native function calling** — typed structured output for sound classification
3. **Multi-turn chat with role separation** — emergency operator simulation and conversation mode
4. **Model weight flexibility** — routing between edge and full models for latency/accuracy tradeoffs

---

## Tracks

**Primary:** Digital Equity & Inclusivity  
**Secondary:** Ollama Special Tech Track — Gemma 4 runs entirely via Ollama, locally, with intelligent routing between Gemma 4 weight classes.

---

## Code Repository

[https://github.com/Medialordofficial/Ishara](https://github.com/Medialordofficial/Ishara)

The repository includes full source code, 342 tests, CI/CD pipeline, and documentation covering architecture, API reference, deployment guide, security model, and AI metrics.

---

*Word count: ~1,200 words*
