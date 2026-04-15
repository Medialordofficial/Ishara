# Changelog

All notable changes to Ishara are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Planned
- Multi-frame sign sequence interpretation (temporal context for motion signs)
- Streaming chat responses for reduced latency
- Offline sign dictionary (cached, no server required)
- RTL language support

---

## [1.3.0] — 2025 Hackathon Release (Current)

### Added
- Encrypted API key storage using `flutter_secure_storage`
- `X-API-Key` header injected on all HTTP requests when configured
- HTTPS warning logged when connecting to non-local hosts over plain HTTP
- Server connectivity indicator on home screen with refresh button
- Camera initialization error handling with user-facing messages in all screens
- Backend `.env.example` for environment variable documentation
- 10 Pydantic response models for all FastAPI endpoints (typed I/O)
- 13 new backend endpoint tests (39 total)
- 8 new `LearnSignsScreen` widget tests
- 7 new `WorldReaderScreen` widget tests
- 7 new `ProgressService` persistence tests
- `docs/API_REFERENCE.md` — complete endpoint documentation with examples
- `docs/DEPLOYMENT.md` — production deployment runbook with FAQ

### Changed
- All backend endpoints return typed Pydantic models instead of raw dicts
- Exception handling uses `raise ... from exc` for proper traceback chaining
- `flutter analyze` reports zero issues (full lint clean)

### Fixed
- `AppColors.primary.toARGB32()` used instead of deprecated `.value`
- Dangling doc comments converted to regular comments
- Unused imports removed from integration tests
- Curly braces added to if-statements in pose detection service

---

## [1.2.0] — 2025 Hackathon Release

### Added
- 9 `EmergencyScreen` widget tests
- 8 `SoundAwarenessScreen` widget tests
- `docs/SECURITY.md` — threat model, HTTPS setup, audit logging, prompt injection
- Prompt injection sanitizer (`_sanitize_user_input`) with regex filters
- Server-side request audit logging
- Per-endpoint Pydantic validation for all inputs

### Fixed
- Sound awareness screen icon and text assertions
- Analyzer suppress comments for deprecated `SemanticsService.announce`

---

## [1.1.0] — 2025 Hackathon Release

### Added
- On-device ML pose detection gating (70% API call reduction)
- `PoseDetectionService` with confidence scoring
- `ProgressService` with streaks, XP, and 10 levels
- Gamification in `LearnSignsScreen` (level badges, streak counter)
- User-facing accessibility guide (`docs/ACCESSIBILITY.md`)
- AI performance metrics (`docs/AI_METRICS.md`)
- `CONTRIBUTING.md` with development setup
- Multiple widget + unit test suites (157 total at time of release)

### Changed
- Retry logic with exponential backoff (500ms, 1s) in `ApiService`
- Custom sealed exception hierarchy (`IsharaApiException`)
- TTS announces sign interpretations for screen reader users

---

## [1.0.0] — Initial Hackathon Submission

### Added
- **5 AI-powered communication modes**:
  - Live Sign Interpretation (camera → Gemma 4 → text + TTS)
  - Sound Awareness (microphone → Gemma 4 → alert classification)
  - Emergency SOS (GPS + type → Gemma 4 → message ready to send)
  - World Reader (camera → Gemma 4 → descriptive text)
  - Sign Language Learning (guided practice with gamification)
- **Sign Dictionary** with 100+ signs across 8 categories
- **Ishara AI** chat with sign language translation overlay
- **Dark mode** with persistent theme preference
- **Settings screen** with server configuration, theme, quick-start guide
- FastAPI backend bridging Flutter app to Gemma 4 26B via Ollama
- Server-side rate limiting (30 req/min per IP)
- Optional API key authentication
- CORS middleware
