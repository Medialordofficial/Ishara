# Contributing to Ishara

## Development Setup

### Prerequisites
- Flutter SDK 3.22+ (Dart 3.4+)
- Python 3.10+
- Android Studio or VS Code with Flutter extension
- Ollama installed on your machine

### Clone & Install

```bash
git clone https://github.com/Medialordofficial/Ishara.git
cd Ishara

# Flutter dependencies
flutter pub get

# Backend dependencies
cd backend
python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install fastapi uvicorn httpx pydantic pytest
```

### Running the App

```bash
# Start Ollama + Gemma 4
ollama serve &
ollama pull gemma4

# Start Backend
cd backend && python server.py

# Run Flutter App  
flutter run
```

## Project Structure

```
lib/
├── main.dart           # Entry point, theme, navigation
├── screens/            # UI screens (one per mode)
├── services/           # Business logic (API, ML, TTS, notifications)
├── models/             # Data classes
├── data/               # Static data (sign dictionary)
└── utils/              # Constants, themes
backend/
├── server.py           # FastAPI server
├── test_server.py      # Backend tests
└── README.md
test/
├── screens/            # Widget tests
├── services/           # Service unit tests
├── models/             # Model tests
├── integration/        # Cross-component tests
└── utils/              # Constants + theme tests
docs/
├── ARCHITECTURE.md     # Design decisions + data flows
├── ACCESSIBILITY.md    # WCAG conformance + a11y design
├── USER_GUIDE.md       # End-user documentation
└── AI_METRICS.md       # AI/ML accuracy + performance
```

## Running Tests

```bash
# All Flutter tests
flutter test

# Single test file
flutter test test/services/api_service_test.dart

# Backend tests
cd backend
source .venv/bin/activate
pytest test_server.py -v

# Flutter analyzer
flutter analyze lib/
```

## Code Style

- Follow [Effective Dart](https://dart.dev/effective-dart) guidelines
- Use `dart format` before committing
- No warnings from `flutter analyze`
- Backend follows PEP 8

## Pull Request Guidelines

1. **Create a branch**: `git checkout -b feature/your-feature`
   - Use prefixes: `feat/`, `fix/`, `test/`, `docs/`, `chore/`, `perf/`
2. **Write tests**: All new features need unit or widget tests
3. **Run tests**: Ensure all tests pass before submitting. Current baseline: **342 tests** (259 Flutter + 83 backend)
4. **Run analyzer**: `flutter analyze lib/` should show 0 errors
5. **Keep PRs small**: One feature or fix per PR
6. **Describe changes**: Include what, why, and how in the PR description

## Commit Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short summary>

[optional body]

[optional footer]
```

**Types**: `feat`, `fix`, `test`, `docs`, `refactor`, `chore`, `perf`

**Examples**:
```
feat(accessibility): replace GestureDetector with InkWell for keyboard focus
fix(security): prune empty rate-limit keys to prevent memory leak
test(backend): add emergency-chat history threading test
```

## Accessibility Requirements

- All interactive widgets must have a `Semantics` label or use a widget that provides one inherently (`ElevatedButton`, `IconButton`, `InkWell`, etc.)
- Colors must meet **WCAG AA** contrast (≥ 4.5:1) — use `AppColors` constants
- Do not use `GestureDetector` for primary actions — prefer `InkWell` or `IconButton`

## Deployment Guide

### Local Development (Recommended)
The default setup runs entirely on your local network:

1. Ollama on a machine with 16+ GB VRAM (GPU recommended)
2. Backend on the same machine or any LAN-accessible host
3. Flutter app on an Android device connected to the same WiFi

### Production Considerations

| Concern | Recommendation |
|---------|---------------|
| HTTPS | Use a reverse proxy (nginx, Caddy) with TLS certificates for any non-LAN deployment |
| API Key | Set `ISHARA_API_KEY` env var and configure the app to send it |
| Rate Limiting | Default 30 req/min/IP; adjust via `ISHARA_RATE_LIMIT` env var |
| CORS | Set `ISHARA_CORS_ORIGINS` to restrict allowed origins |
| Persistence | Rate limit store is in-memory; use Redis for production deployments |
| Monitoring | Backend logs all requests; forward to a log aggregation service |
| Model | Gemma 4 (26B) needs ~16 GB VRAM; use `gemma4:12b` for smaller GPUs |

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OLLAMA_URL` | `http://localhost:11434` | Ollama API endpoint |
| `ISHARA_MODEL` | `gemma4` | Ollama model name |
| `ISHARA_API_KEY` | (empty) | Set to require API key auth |
| `ISHARA_RATE_LIMIT` | `30` | Max requests per IP per minute |
| `ISHARA_CORS_ORIGINS` | `http://localhost:8080,http://localhost:3000` | Comma-separated allowed origins |
| `ISHARA_SIGN_LANGUAGE` | `ASL (American Sign Language)` | Sign language dialect used in prompts |

## License

This project is part of the Google AI Hackathon. See repository for license details.
