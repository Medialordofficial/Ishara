# Ishara API Reference

## Base URL

```
http://<server-ip>:8000
```

## Authentication

Set `ISHARA_API_KEY` on the server to enable API key authentication. Pass the key via the `X-API-Key` header.

```http
X-API-Key: your-secret-key
```

Exempt paths (no auth required): `/ping`, `/health`, `/docs`, `/openapi.json`, `/redoc`

## Rate Limiting

- **Default**: 30 requests/minute per IP
- **Configurable**: Set `ISHARA_RATE_LIMIT` environment variable
- **Exempt paths**: `/ping`, `/health`, `/docs`, `/openapi.json`, `/redoc`
- **Response**: HTTP 429 with `{"detail": "Rate limit exceeded. Try again later."}`

---

## Endpoints

### GET /ping

Health check — lightweight.

**Response** `200`
```json
{
  "status": "ok",
  "model": "gemma4"
}
```

---

### GET /health

Detailed health check including Ollama status.

**Response** `200`
```json
{
  "status": "ok",
  "ollama": true,
  "model": "gemma4"
}
```

---

### POST /interpret-sign

Interpret a sign language gesture from a camera frame.

**Request**: `multipart/form-data`
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `image` | File | Yes | JPEG/PNG/WebP/GIF, max 10 MB |

**Response** `200`
```json
{
  "sign": "Hello",
  "confidence": 0.85
}
```

| Field | Type | Description |
|-------|------|-------------|
| `sign` | string | Interpreted sign text, or `"No sign detected"` |
| `confidence` | float | Model certainty 0.0–1.0 (0 indicates parsing fallback) |

**Errors**: `400` (unsupported type), `413` (too large), `503` (Ollama offline), `504` (timeout)

---

### POST /speech-to-text

Server-side STT placeholder (primary STT is on-device).

**Request**: `application/json`
```json
{
  "audio_b64": "base64-encoded-audio"
}
```

**Response** `200`
```json
{
  "text": "[Server STT not yet available]",
  "available": false
}
```

---

### POST /classify-sound

Classify a sound detected by the microphone.

**Request**: `application/json`
```json
{
  "description": "loud beeping noise"
}
```

**Response** `200`
```json
{
  "sound": "alarm",
  "level": "critical",
  "description": "A fire alarm or smoke detector beeping"
}
```

Sound categories: `doorbell`, `alarm`, `car_horn`, `dog_bark`, `baby_cry`, `siren`, `speech`, `appliance`, `music`, `knock`, `other`

Urgency levels: `critical`, `warning`, `info`

---

### POST /emergency-message

Generate an emergency SOS message.

**Request**: `application/json`
```json
{
  "emergency_type": "medical",
  "latitude": 6.5244,
  "longitude": 3.3792
}
```

Allowed types: `medical`, `police`, `fire`, `natural_disaster`, `other`

**Response** `200`
```json
{
  "message": "EMERGENCY: Medical emergency at coordinates 6.5244, 3.3792. I am deaf and cannot make voice calls. Please send medical assistance immediately."
}
```

**Errors**: `400` (invalid emergency type)

---

### POST /emergency-chat

Chat with a simulated emergency dispatcher.

**Request**: `application/json`
```json
{
  "message": "I need an ambulance",
  "context": "medical emergency, broken leg"
}
```

| Field | Type | Required | Max Length |
|-------|------|----------|-----------|
| `message` | string | Yes | 2000 chars |
| `context` | string | No | — |

**Response** `200`
```json
{
  "reply": "Help is on the way. Can you confirm your exact location?"
}
```

---

### POST /read-world

Read and describe what the camera sees.

**Request**: `multipart/form-data`
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `image` | File | Yes | JPEG/PNG/WebP/GIF, max 10 MB |
| `question` | string | No | Specific question about the scene |

**Response** `200`
```json
{
  "description": "A restaurant menu board showing: Burger $12, Pizza $15, Salad $8. The sign appears to be at a casual dining restaurant."
}
```

---

### POST /evaluate-sign

Evaluate a user's sign language attempt.

**Request**: `multipart/form-data`
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `image` | File | Yes | JPEG/PNG/WebP/GIF, max 10 MB |
| `target_sign` | string | Yes | The sign being attempted |

**Response** `200`
```json
{
  "feedback": "Good hand position! Try raising your fingers a bit higher for a clearer 'Hello' sign."
}
```

---

### POST /chat

General AI assistant conversation.

**Request**: `application/json`
```json
{
  "message": "How do I sign 'thank you'?",
  "history": [
    {"role": "user", "content": "Hi"},
    {"role": "assistant", "content": "Hello! How can I help?"}
  ]
}
```

| Field | Type | Required | Max Length |
|-------|------|----------|-----------|
| `message` | string | Yes | 2000 chars |
| `history` | array | No | Last 6 entries used |

**Response** `200`
```json
{
  "reply": "To sign 'thank you', extend your fingers from your chin outward, like blowing a kiss..."
}
```

---

## Auto-generated Documentation

FastAPI auto-generates interactive API docs:
- **Swagger UI**: `http://<server-ip>:8000/docs`
- **ReDoc**: `http://<server-ip>:8000/redoc`
- **OpenAPI JSON**: `http://<server-ip>:8000/openapi.json`

## Error Responses

All errors follow this format:
```json
{
  "detail": "Human-readable error description"
}
```

| Code | Meaning |
|------|---------|
| 400 | Invalid input (bad type, too long, etc.) |
| 401 | Invalid or missing API key |
| 413 | Image too large (>10 MB) |
| 422 | Missing required fields |
| 429 | Rate limit exceeded |
| 502 | Ollama returned an error |
| 503 | Cannot reach Ollama |
| 504 | Ollama request timed out |
