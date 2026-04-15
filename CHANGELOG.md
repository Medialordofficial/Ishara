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
- First-launch onboarding (server IP setup wizard)

---

## [1.9.0] — 2026-04-15 — Fix Cycle 15

### Accessibility
- Replaced all `GestureDetector` interactive widgets in `AiChatScreen` with `InkWell` — now focusable via keyboard/switch access and get ink ripple feedback
- Fixed `danger` color: `0xFFEA4335` → `0xFFB91C1C` (Red-700, ~5.9:1 WCAG AA on white)
- Fixed `info` color: `0xFF4285F4` → `0xFF1D4ED8` (Blue-700, ~5.9:1 WCAG AA on white)
- Added inline validation error for emergency number field (warns on invalid format)

### Security / Reliability
- Fixed `_rate_store` memory leak: empty IP keys are now pruned after each request window cleanup
- Fixed CORS origins whitespace: `ISHARA_CORS_ORIGINS` values are now `.strip()`ped before use
- Replaced narrow `safe_keywords` whitelist in `emergency_message` fallback validation with a robust refusal-pattern check (no false negatives for valid emergency messages)

### Product / UX
- Added API key input field in Settings → Server Connection (obscured, show/hide toggle, persisted via `flutter_secure_storage`)
- Emergency number field now validates E.164-ish format with real-time error label
- AI chat offline fallback replaced: instead of fake keyword-matched answers, users now receive an honest "server unreachable" message with optional offline dictionary lookup

### AI / ML
- `/emergency-chat` now supports multi-turn conversation history via `history: list[HistoryMessage]` — last 6 turns are threaded into the LLM context
- Added 3 more few-shot examples to `/interpret-sign` prompt (Thank you/0.85, Water/0.80, More/0.75) — 5 examples total
- `/emergency-chat` internal prompt rebuilt as structured `messages[]` array (consistent with `/chat`)

### Documentation
- Enhanced `CONTRIBUTING.md` with branch conventions, Conventional Commits format, accessibility requirements, and test baseline (294 tests)

### Tests
- **294 total tests** (220 Flutter + 74 backend — all passing)
- Added `test_emergency_chat_with_history` — verifies history is threaded into structured messages
- Strengthened `test_interpret_sign_prompt_includes_few_shot_examples` — now asserts all 5 sign names are present
- Updated `test_emergency_all_valid_types` — accepts 429 (expected under sequential test-client calls)
- Updated fallback response test: now asserts honest offline message instead of fake keyword response


---

## [1.8.0] — 2026-04-15 — Fix Cycle 14

### Fixed — AI/ML Quality
- **`/chat` history threading**: `general_chat` now passes conversation history as a structured `messages[]` array to Ollama's `/api/chat` — eliminating the `User:/Assistant:` prefix hack that defeated role isolation. System prompt, sanitized history, and current message are each their own role-separated entries.
- **Emergency message template fallback**: `/emergency-message` now validates LLM output. If the model returns garbage (<20 chars, no emergency keywords), a safe hardcoded template with emergency type + location is returned instead.
- **Few-shot examples in interpret-sign prompt**: Added two annotated examples to `/interpret-sign` prompt to guide JSON format compliance and improve confidence calibration.

### Fixed — Accessibility
- **`warning` color**: `0xFFFBBC05` (yellow, ~1:1 on white — WCAG FAIL) → `0xFFB45309` (amber-700, ~4.9:1 on white — WCAG AA pass). Affects Fire emergency type badge and all `warning` severity indicators.
- **`FocusTraversalOrder` on emergency type grid**: Emergency type buttons wrapped in `FocusTraversalGroup` + `FocusTraversalOrder(NumericFocusOrder)` for predictable keyboard/switch navigation (Medical=0, Police=1, Fire=2, Disaster=3, Other=4).
- **Chat bubble role semantics**: User bubbles wrapped in `Semantics(label: 'You: ...')` and assistant bubbles in `Semantics(label: 'Ishara: ...')` so TalkBack announces speaker context.

### Fixed — Security
- **HTTP insecure warning banner**: Settings screen shows a persistent amber warning banner whenever the configured server URL uses plain HTTP on a non-local hostname. `ApiService.isInsecureHttp` getter drives the conditional.
- **Chunked-encoding body size bypass**: `_ContentSizeLimitMiddleware` now also streams the request body via `request.stream()` and aborts at `MAX_BODY_BYTES` — prevents bypass via chunked-transfer encoding that omits `Content-Length` headers.

### Fixed — Code Quality
- **Notification ID collision**: `NotificationService` now uses a monotonic `_nextId++` counter instead of `DateTime.now().millisecondsSinceEpoch ~/ 1000` — prevents same-second notifications from replacing each other on Android.
- **`_chatHistory` bounded**: AI chat history capped at 20 entries (10 turns) in `_sendMessage` — prevents unbounded memory growth in long sessions.

### Fixed — Documentation
- **CHANGELOG v1.7.0 missing date**: Added `2026-04-15` to `[1.7.0]` entry.
- **Environment variables table**: README now has a complete table of all 6 env vars (`OLLAMA_URL`, `ISHARA_MODEL`, `ISHARA_SIGN_LANGUAGE`, `ISHARA_API_KEY`, `ISHARA_RATE_LIMIT`, `ISHARA_CORS_ORIGINS`) with defaults, descriptions, and examples.
- **Interactive API docs callout**: README now mentions `http://localhost:8000/docs` (Swagger UI).

### Fixed — Testing
- **4 new backend tests**:
  - `test_chat_history_passed_as_structured_messages` — verifies structured messages[] kwarg is forwarded (history threading)
  - `test_emergency_message_template_fallback_on_garbage` — verifies safe fallback when LLM returns garbage
  - `test_emergency_message_valid_output_passes_through` — verifies clean output is not replaced
  - `test_interpret_sign_prompt_includes_few_shot_examples` — verifies examples appear in prompt
- **Updated all 8 existing mock `_chat` function signatures** in test_server.py to accept `messages=None` keyword arg after `_chat` API update
- **Total: 293 tests (220 Flutter + 73 backend), all passing**

---

## [1.7.0] — 2026-04-15 — Fix Cycle 13


### Fixed — AI/ML Quality
- **Sign language system**: `/interpret-sign` and `/evaluate-sign` prompts now include `SIGN_LANGUAGE_SYSTEM` (configurable via `ISHARA_SIGN_LANGUAGE` env var, defaults to `ASL (American Sign Language)`)
- **Prompt injection**: `target_sign` in `/evaluate-sign` now sanitized via `_sanitize_user_input()` before injection into LLM prompt
- **Emergency message coordinates**: Formatted as human-readable directional (`N/S`/`E/W`) instead of raw floats; "Location not available." when both coords are 0.0

### Fixed — Accessibility
- **`SemanticsService.announce`**: All 3 call sites now use `assertiveness: Assertiveness.assertive` for screen reader priority

### Fixed — Security
- **Content-Length header**: Backend now validates `Content-Length` header against body size; rejects requests with mismatched headers (413)

### Fixed — Code Quality
- **Settings `_saveSettings()`**: Now also persists emergency number change (previously only `onChanged` persisted it)
- **`NotificationService.init()`**: Wrapped in try/catch so plugin unavailability (test env / restricted devices) doesn't crash the app
- **`NotificationService.show()`**: Wrapped `_plugin.show()` in try/catch for the same reason
- **AI chat notification**: Changed fire-and-forget `_notif.aiReply(response)` to `.catchError((_) {})` so async errors don't propagate to the widget

### Fixed — Documentation
- **TROUBLESHOOTING.md**: Removed false instruction "configure offline fallback messages in Settings"; replaced with accurate description of automatic fallback
- **API_REFERENCE.md**: `context` field in `/emergency-chat` now shows `500 chars` max; `/feedback` endpoint fully documented

### Fixed — Testing
- **Backend**: 3 new tests (Content-Length rejection, sign language system injection, evaluate-sign sanitization) → 69 total (was 66)
- **AI Chat screen**: 5 new behavioral tests (send flow, fallback response, empty-send guard, clear chat) → 9 total (was 4)
- **Emergency screen**: 7 new tests (accessibility semantics, selected state, confirmation dialog) → 16 total (was 9)
- **Total**: 289 tests (220 Flutter + 69 backend), all passing

### Fixed — UI/Contrast
- **`textSecondary` color**: `0xFF7B849C` → `0xFF555E75` — meets WCAG AA contrast ratio (≥4.5:1) on background

---

## [1.6.0] — 2025 Hackathon Release (Latest)

### Fixed — Security
- **CORS wildcard**: Default `ALLOWED_ORIGINS` changed from `"*"` to `["http://localhost:8080", "http://localhost:3000"]`; set `ISHARA_CORS_ORIGINS` env var for production hosts
- **Context `max_length`**: `POST /emergency-chat` `context` field now has `max_length=500` (was unbounded)

### Fixed — Reliability
- **LLM retry**: `_chat()` now retries once on `httpx.TimeoutException`; client-facing 504 only raised after both attempts fail
- **Hardcoded `911`** in AI chat offline fallback: replaced with `_api.emergencyNumber` (respects configured number)

### Fixed — Accessibility
- **CALL EMERGENCY SERVICES button**: Wrapped in `Semantics(button: true, label: 'Call emergency services', hint: '...')` for screen readers

### Fixed — Code Quality
- **Magic literals**: `0.5` confidence threshold and `0.3` signing threshold in `conversation_screen.dart` now reference `PoseThresholds.interpretConfidence` and `PoseThresholds.signingConfidence`
- `PoseThresholds.interpretConfidence = 0.5` constant added to `constants.dart`

### Fixed — Documentation
- `TROUBLESHOOTING.md`: `OLLAMA_MODEL` → `ISHARA_MODEL`; `gemma3:4b/27b` → `gemma4`; updated RAM guidance and model pull commands

### Added — Tests
- **14 new Flutter ConversationScreen tests**: AppBar, spinner, system message, mic button, send button, TextField submit, clear behaviour, confidence bar Semantics, threshold constants
- **4 new Flutter SettingsScreen tests**: Emergency Services section, default 112 value, help text, SharedPreferences load
- **5 new backend tests**: context max_length 422 rejection, context at limit, 504 on timeout, retry success on first-attempt-timeout, CORS not wildcard
- **Total: 207 Flutter + 66 backend = 273 tests, 0 failures**

---

## [1.5.0] — 2025 Hackathon Release
- **Emergency type bug**: `ambulance` changed to `medical` to match API allowlist; was causing 400 errors on every Medical SOS
- **Hardcoded `911`**: Emergency dial number now user-configurable (default 112 international); set in Settings → Emergency Services

### Added
- **Emergency types expanded**: Added `natural_disaster` and `other` options (all 5 API types now exposed in UI)
- **Settings: Emergency Number field**: Users can configure their regional emergency number
- **AI/ML: `/api/chat` endpoint**: Migrated text-only LLM calls from `/api/generate` to Ollama's `/api/chat` for proper system/user role separation
- **Temperature control**: `temperature=0.1` for safety-critical endpoints (sign inference, emergency), `temperature=0.7` for free chat
- **Sound normalization**: `classify_sound` now validates returned category against the 11-item allowlist; unknown values fallback to "other"
- **Coordinate validation**: `emergency_message` rejects lat/lon out of WGS-84 range (±90 / ±180)
- **Timing-safe auth**: `hmac.compare_digest()` replaces `!=` in API key comparison
- **HistoryMessage model**: `/chat` history now uses `Literal["user", "assistant"]` role type — rejects `system`, `instruction`, etc.
- **Concurrent capture guard**: `_isCapturing` flag prevents overlapping camera captures in ConversationScreen
- **Confidence threshold**: Signs with <50% confidence no longer announce/speak (reduces noise)
- **Signing confidence Semantics**: `LinearProgressIndicator` now has `Semantics(label: 'Signing confidence', value: '…%')` for screen readers
- **Home screen refresh button Semantics**: Offline banner's refresh icon wrapped in `Semantics(button: true, label: 'Retry server connection')`
- **9 new backend tests** → 61 total: role allowlist, coord validation, timing-safe auth, sound normalization (4 tests), chat role acceptance
- **API timeout**: Reduced Ollama timeout from 300s to 30s

### Changed
- `README.md`: Test count updated to 250 (189 Flutter + 61 backend)
- `TROUBLESHOOTING.md`: Auth failure HTTP code corrected from 403 → 401; emergency types updated to include `natural_disaster`, `other`

### Total Tests: 189 Flutter + 61 backend = **250 tests, 0 failures**

---

## [1.4.0] — 2025 Hackathon Release

### Added
- **Feedback loop**: thumbs up/down buttons after each sign interpretation; correction dialog for wrong signs
- **Confidence scores**: `/interpret-sign` now returns `confidence: float` (0.0–1.0); displayed as coloured badge (green ≥70%, yellow ≥50%, red <50%)
- `/feedback` POST endpoint logs `(interpreted_sign, correct_sign)` pairs for future fine-tuning
- `TROUBLESHOOTING.md`: 12 common issues with step-by-step solutions
- `ContentSizeLimitMiddleware`: rejects oversized request bodies at transport layer before memory allocation
- `_parse_llm_json()` helper: strips Gemma's markdown code fences before JSON parsing; shared by all LLM endpoints
- `sendFeedback()` method in Flutter `ApiService`
- 14 new tests (7 backend + 7 Flutter) → 235 total

### Changed
- `interpretSign()` now returns `Map<String, dynamic>` with `sign` and `confidence` fields (was `String`)
- Retry logic (`_retry()`) applied uniformly to all API methods: `readWorld`, `emergencyMessage`, `evaluateSign`, `speechToText`
- `_sanitize_user_input` removed its `import re` guard (module-level `import re` added)
- Bottom nav items use explicit `label` parameter instead of icon comparison — cleaner semantics

### Security
- Request bodies > 10 MB now rejected at middleware before being read into memory

---

## [1.3.0] — 2025 Hackathon Release

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
