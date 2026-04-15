# Ishara Backend

FastAPI server bridging the Flutter app and **Gemma 4** (via [Ollama](https://ollama.com)).

## Prerequisites

| Requirement | Version |
|---|---|
| Python | 3.10+ |
| Ollama | latest |
| RAM | 16 GB+ recommended (Gemma 4 26B needs ~16 GB VRAM) |

## Quick Start

```bash
# 1. Install Python dependencies
pip install fastapi uvicorn httpx python-multipart pydantic

# 2. Install and start Ollama
brew install ollama   # macOS
ollama serve          # start the daemon

# 3. Pull the Gemma 4 model
ollama pull gemma4

# 4. Start the Ishara backend
python server.py
# Server runs at http://0.0.0.0:8000
```

## Configuration

All configuration is via environment variables:

| Variable | Default | Description |
|---|---|---|
| `OLLAMA_URL` | `http://localhost:11434` | Ollama API endpoint |
| `ISHARA_MODEL` | `gemma4` | Model name to use |
| `ISHARA_RATE_LIMIT` | `30` | Max requests per IP per minute |
| `ISHARA_API_KEY` | *(empty — auth disabled)* | Set to enable API key authentication |
| `ISHARA_CORS_ORIGINS` | `*` | Comma-separated allowed CORS origins |

### Enabling Authentication

```bash
export ISHARA_API_KEY="your-secret-key"
python server.py
```

The app must then send `X-API-Key: your-secret-key` in every request header. The `/ping`, `/health`, `/docs`, and `/redoc` endpoints are exempt.

## API Endpoints

| Method | Path | Description |
|---|---|---|
| `GET` | `/ping` | Health check — returns `{"status": "ok"}` |
| `GET` | `/health` | Extended health — checks Ollama connectivity |
| `POST` | `/interpret-sign` | Interpret sign language from camera frame (multipart image) |
| `POST` | `/classify-sound` | Classify a sound description as doorbell, alarm, etc. |
| `POST` | `/emergency-message` | Generate an emergency message for a deaf user |
| `POST` | `/emergency-chat` | Chat with simulated emergency dispatcher |
| `POST` | `/read-world` | Describe what the camera sees (multipart image + optional question) |
| `POST` | `/evaluate-sign` | Evaluate a user's sign attempt (multipart image + target sign) |
| `POST` | `/chat` | General LLM conversation |
| `POST` | `/speech-to-text` | Placeholder for server-side STT (not yet implemented) |

Interactive API docs available at: `http://localhost:8000/docs`

## Finding Your Local IP

The Flutter app needs your laptop's IP to connect:

```bash
# macOS
ipconfig getifaddr en0

# Linux
hostname -I | awk '{print $1}'

# Windows
ipconfig | findstr "IPv4"
```

Enter this IP in the Ishara app's Settings screen.

## Running Tests

```bash
pip install pytest
cd backend
pytest test_server.py -v
```

## Security Notes

- **Rate limiting**: 30 requests/minute per IP (configurable via `ISHARA_RATE_LIMIT`)
- **Image validation**: Max 10 MB, JPEG/PNG/WebP/GIF only
- **Text limits**: Max 2000 characters per message
- **Authentication**: Optional API key via `ISHARA_API_KEY` environment variable
- **Emergency types**: Allowlisted to `medical`, `police`, `fire`, `natural_disaster`, `other`
