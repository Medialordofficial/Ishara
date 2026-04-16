# Ishara — AI/ML Performance Metrics

## Models Used

| Component | Model | Location | Purpose |
|-----------|-------|----------|---------|
| Sign Language Interpretation | Google Gemma 4 (26B) | Local via Ollama | Multimodal sign → text |
| Pose Detection | Google ML Kit Pose Detection | On-device | 33-landmark body tracking |
| Sound Classification | Google Gemma 4 (26B) | Local via Ollama | Audio description → category |
| World Reading | Google Gemma 4 (26B) | Local via Ollama | Multimodal image → text |
| Text-to-Speech | Flutter TTS | On-device | AI response vocalization |

## Pose Detection Performance

### Frame Gating Efficiency
The on-device ML Kit pose detection acts as a smart filter, reducing backend API calls:

| Metric | Value |
|--------|-------|
| Detection rate | 30 fps real-time |
| Landmarks tracked | 33 body landmarks |
| Signing confidence threshold | 0.3 (configurable) |
| Estimated API call reduction | ~70% of frames filtered |

### Scoring Algorithm
The signing confidence score (0–1.0) is computed from three weighted components:

| Component | Weight | Description |
|-----------|--------|-------------|
| Hand visibility | 0.4 | Both hands detected with high confidence |
| Hand position | 0.3 | Hands within signing zone (raised, near face/chest) |
| Frame quality | 0.3 | Hand landmark count within valid range (50–600 px) |

A score above **0.3** triggers frame capture and backend inference.

## Sign Interpretation Accuracy

### Methodology
Tested with common ASL signs performed by 1 user under controlled conditions (good lighting, plain background).

| Condition | Expected Accuracy | Notes |
|-----------|-------------------|-------|
| Common single-word signs (hello, thank you, yes, no) | 70–85% | Gemma 4 multimodal handles static poses well |
| Two-handed signs | 60–75% | More spatial complexity |
| Signs requiring motion | 40–60% | Single frame lacks temporal context |
| Poor lighting | 30–50% | Degraded image quality reduces accuracy |

### Limitations
- **Single-frame limitation**: Current architecture sends one frame per detection cycle. Signs that require motion (e.g., "finish", "change") lose temporal context.
- **No fine-tuning**: Using Gemma 4's general multimodal capabilities, not a specialized ASL model.
- **User variation**: Accuracy varies with signing style, hand size, and skin tone contrast.
- **Vocabulary**: Not limited to a fixed vocabulary — Gemma 4 can interpret any sign it recognizes, but accuracy is best for common signs.

## Sound Classification Performance

### Categories
The sound classifier maps microphone descriptions to 11 categories:

| Category | Urgency | Example Sounds |
|----------|---------|----------------|
| alarm | critical | Fire alarm, smoke detector |
| siren | critical | Ambulance, police, fire truck |
| baby_cry | critical | Infant crying |
| car_horn | warning | Vehicle horn |
| dog_bark | warning | Dogs barking |
| knock | warning | Door knock |
| doorbell | info | Doorbell ring |
| speech | info | Human voices |
| appliance | info | Microwave beep, washing machine |
| music | info | Background music |
| other | info | Unclassified sounds |

### Threshold Configuration

| Level | Default (dB) | Description |
|-------|-------------|-------------|
| Warning | 75 dB | Elevated ambient noise (conversation level) |
| Critical | 90 dB | Potentially dangerous noise level |
| Max | 130 dB | Sensor ceiling |

## Latency Benchmarks

Measured on a local WiFi network with Ollama running on a machine with NVIDIA RTX 3090:

| Operation | Typical Latency | Timeout |
|-----------|----------------|---------|
| Ping / health check | < 50ms | 3s |
| Sign interpretation | 2–5s | 30s |
| Sound classification | 1–3s | 15s |
| Emergency message | 2–4s | 15s |
| World reading | 3–6s | 30s |
| AI chat | 1–4s | 30s |
| Pose detection (on-device) | ~33ms (30 fps) | N/A |

### Retry Behavior
The system uses two complementary layers of fault-tolerance:

**Server-side circuit breaker** (backend `_chat()`, added v2.5.0):
- 3 consecutive `ConnectError`s open the circuit for 30 seconds, returning 503 immediately without waiting for Ollama's 5-second connect timeout.
- After 30 s the circuit half-opens; a probe failure immediately re-opens it.
- On a successful Ollama response the failure count resets to 0.

**Client-side retry** (Flutter `ApiService`), for transient non-connection failures:
- Attempt 1: Immediate
- Attempt 2: After 500ms
- Attempt 3: After 1000ms

After 3 total attempts, a `RetryExhaustedException` is thrown.

> Note: When the circuit is open the server returns 503 before the client's retry layer can trigger a new Ollama `ConnectError`.

## Privacy Architecture

```
┌─────────────┐    WiFi (LAN)    ┌──────────────┐    localhost    ┌─────────┐
│  Mobile App  │ ──────────────→ │   FastAPI     │ ─────────────→ │  Ollama │
│  (Flutter)   │                 │   Backend     │                │  Gemma 4│
│  + ML Kit    │ ←────────────── │   (Python)    │ ←───────────── │  (26B)  │
└─────────────┘                  └──────────────┘                 └─────────┘
      │
      │  On-device only
      ▼
  ML Kit Pose
  Detection
```

**Zero external network calls.** All data remains on the user's local network.

## Future Improvements

1. **Multi-frame sign detection**: Buffer 3–5 frames and send sequence for motion-dependent signs
2. **Custom ASL model**: Fine-tune a smaller model specifically for ASL recognition
3. **On-device sound classification**: Use TensorFlow Lite YAMNet for offline sound classification
4. **Whisper integration**: Server-side speech-to-text via OpenAI Whisper for the hearing user's voice
5. **User feedback loop**: Let users correct misinterpretations to build training data
