# Changelog

All notable changes to Ishara are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [3.8.0] — Fix Cycle 34

### Accessibility
- `conversation_screen.dart`: `TextField` Semantics: removed erroneous `excludeSemantics: true` (was stripping text-value/cursor/editing-action semantic nodes); changed `hintText` to `'Type here…'` to avoid duplicate announcement with label
- `conversation_screen.dart`: thumb-up/thumb-down `IconButton` wrappers simplified — outer `Semantics(button:true)` removed; use `IconButton(tooltip:)` directly (matches `delete_outline` pattern)
- `conversation_screen.dart`: LIVE badge `Row` restored to `const Row` with `ExcludeSemantics` child

### Security
- `conversation_screen.dart`: on-device STT `captured` text and user-typed text in `_sendTextMessage` sanitized via `sanitizeSoundLabel()` before `_addHearingMessage`
- `conversation_screen.dart`: `_listenViaServerStt` fallback path sanitized; empty result after sanitization is now suppressed (no empty bubble)

### Testing
- `sound_awareness_utils_test.dart`: test 16 added — whitespace-only input returns empty string

### Documentation
- `CONTRIBUTING.md`: test baseline updated to 336 tests (253 Flutter + 83 backend)

---

## [3.7.0] — Fix Cycle 33

### Accessibility
- `conversation_screen.dart`: `ExcludeSemantics` added to `Icons.circle` in LIVE badge
- `conversation_screen.dart`: `ExcludeSemantics` added to `Icons.person`/`Icons.person_outline` in signing-status overlay
- `conversation_screen.dart`: `ExcludeSemantics` added to `Icons.auto_graph` in confidence trend row

### Security
- `conversation_screen.dart`: correction dialog user input now sanitized via `sanitizeSoundLabel()` before passing to `sendFeedback()` — prevents prompt injection via the feedback endpoint

### Testing
- `sound_awareness_utils_test.dart`: test 6 truncation bound tightened to `equals(81)` (80 chars + 1-code-unit ellipsis)
- `sound_awareness_utils_test.dart`: test 10 renamed to 'rejects html tag angle brackets as injection'
- `sound_awareness_utils_test.dart`: test 15 renamed to 'all injection strings produce empty output for sanitizeSoundLabel'

---

## [3.6.0] — Fix Cycle 32

### Accessibility
- `conversation_screen.dart`: `TextField` wrapped in `Semantics(label: 'Hearing person types here', textField: true)` for screen-reader clarity
- `conversation_screen.dart`: `ExcludeSemantics` added to `Icons.send_rounded`, `Icons.mic`/`Icons.mic_none`, `Icons.stop`/`Icons.sign_language` (all inside `Semantics(button:true, label:...)` parents)
- `conversation_screen.dart`: server STT `Chip` Semantics wrapper gains `excludeSemantics: true` to prevent dual announcement

### Testing
- `sound_awareness_utils_test.dart`: test 14 — sign interpretation injection strings are stripped to empty
- `sound_awareness_utils_test.dart`: test 15 — all injection patterns produce empty output

### Documentation
- `CHANGELOG.md`: `[3.5.0]` Fix Cycle 31 entry added; `[3.3.0]` repaired to minimal content
- `CONTRIBUTING.md`: test baseline updated to 335 tests (252 Flutter + 83 backend)

---

## [3.5.0] — Fix Cycle 31

### Security
- `conversation_screen.dart`: sign interpretation result from `interpretSign()` now sanitized via `sanitizeSoundLabel()` before insertion into chat and TTS — consistent with STT and sound-label surfaces

### Code Quality
- `conversation_screen.dart`: removed redundant `if (mounted)` guard in `_listenViaServerStt` (unreachable after the preceding `if (!mounted) return`)

### Accessibility
- `sound_awareness_screen.dart`: `ExcludeSemantics` added to listening toggle icon (`Icons.hearing`/`Icons.hearing_disabled`) inside `Semantics(button:true)` parent
- `sound_awareness_screen.dart`: `ExcludeSemantics` added to `_PremiumTestButton` icon
- `sound_awareness_screen.dart`: `ExcludeSemantics` added to decibel `Text` readout (value already announced by `LinearProgressIndicator` Semantics label)

### Testing
- `conversation_screen_test.dart`: test 3 name and mock endpoint URL corrected to `/speech-to-text`

---

## [3.4.0] — Fix Cycle 30

### Bug Fixes
- `conversation_screen.dart`: `onStatus` callback now routes through `_sttServerAvailable` check — was a third code path that bypassed server STT entirely
- `conversation_screen.dart`: `_listenViaServerStt()` disables server STT permanently when `result.available == false` — prevents wasted network calls

### Accessibility
- `sound_awareness_screen.dart`: `ExcludeSemantics` added to decorative `Icons.history` (empty-state) and `Icons.notifications_active` (`_PremiumAlertCard`)

### Testing
- `conversation_screen_test.dart`: 3 new widget tests for server STT chip visibility (ping success → chip shown; ping failure → chip hidden; available=false state)

---

## [3.3.0] — Fix Cycle 29

### Documentation
- `CHANGELOG.md`: added missing `[3.1.0]` and `[3.2.0]` entries

### Testing
- `sound_awareness_utils_test.dart`: added 13th test verifying `sanitizeSoundLabel` reuse for server STT results

---

## [3.2.0] — Fix Cycle 28

### Bug Fix (Critical)
- `conversation_screen.dart`: `_listenViaServerStt()` now takes an explicit `fallbackText` parameter — on server failure or empty response, on-device transcription is delivered instead of being silently lost
- `conversation_screen.dart`: Manual-stop path is now consistent with `onResult` path — both check `_sttServerAvailable` and route through `_listenViaServerStt` when true
- `conversation_screen.dart`: `_checkServerStt()` no longer fires a blind STT inference on cold start — uses `/ping` only (STT availability confirmed lazily on first use)
- `conversation_screen.dart`: `result.text` from server now sanitized via `sanitizeSoundLabel` before insertion into chat

### Testing
- `sound_awareness_utils_test.dart`: 13 unit tests for `sanitizeSoundLabel()` (empty, injection, truncation, control characters, data:, javascript: schemes)
- CONTRIBUTING.md: test count updated to 330 (247 Flutter + 83 backend)

---

## [3.1.0] — Fix Cycle 27

### Server STT Integration
- `conversation_screen.dart`: `_checkServerStt()` probes server on init — sets `_sttServerAvailable` flag
- `conversation_screen.dart`: `_toggleMic()` routes recognized speech through server STT when `_sttServerAvailable = true`; shows "Server STT active — routing speech" chip
- `conversation_screen.dart`: `_listenViaServerStt()` method sends audio to server with on-device fallback

### Sound Classification Quality
- `sound_awareness_screen.dart`: `sanitizeSoundLabel()` extracted as testable top-level function
- `sound_awareness_screen.dart`: `_updateLastAlertLabel()` updates existing alert in-place — eliminates duplicate screen-reader announcements for same sound event
- `sound_awareness_screen.dart`: Uses `_currentDecibel` (real ambient reading) as noise floor — was `db - 20` approximation

### Bug Fix
- `sound_awareness_screen.dart`: LLM-returned classification labels sanitized before display/announcement

---

## [3.0.0] — Fix Cycle 26

### API Contract
- `api_service.dart`: `speechToText()` now sends `{"audio_b64": "..."}` JSON body matching the server `SpeechRequest` model (was multipart)
- `api_service.dart`: `speechToText()` returns `({String text, bool available})` record — clients read `.available` to conditionally enable server STT
- `conversation_screen.dart`: probes server STT availability on init; shows "Server STT active" chip and routes audio through server when `available: true`

### AI/ML Quality
- `sound_awareness_screen.dart`: `_classifyViaBackend()` uses `_currentDecibel` (actual meanDecibel) as noise floor instead of fabricated `db - 20`
- `sound_awareness_screen.dart`: prevents duplicate alert — second `_triggerAlert()` call is skipped if local alert already fired for the same sound event
- `sound_awareness_screen.dart`: LLM-returned label sanitized through `_safeSoundLabel()` before announcement

### Product/UX
- `settings_screen.dart`: "Replay Tutorial" button — clears `ishara_onboarded` and navigates to `OnboardingScreen`

### Documentation
- `backend/README.md`: `ISHARA_STT_AVAILABLE` env var documented on `/speech-to-text` endpoint row
- CHANGELOG retroactively catches up for all C26 changes

### Testing
- `test_server.py`: STT test renamed `test_speech_to_text_response_returns_empty_text_when_disabled` with explicit `""` assertion
- `api_service_http_test.dart`: `speechToText` group updated for JSON body and record return type
- Added widget test: Replay Tutorial button clears `ishara_onboarded` and navigates to `OnboardingScreen`
- Flutter tests: **234 total**; Backend tests: **83**; Total: **317**

---

## [2.9.0] — Fix Cycle 25

### Accessibility
- Onboarding dot indicators wrapped in `Semantics(label: 'Page N of 4', selected: ...)` — screen readers now announce current page position
- Decorative onboarding page icons marked `ExcludeSemantics` — eliminates redundant unlabelled icon announcements

### Reliability
- `main()` `SharedPreferences` reads wrapped in `try/catch` — corrupt storage on Android no longer crashes startup; falls back to system theme + show onboarding

### Testing
- Fixed onboarding test 5: now pumps `IsharaApp(showOnboarding: true)` and asserts `OnboardingScreen` renders (vs. `HomeScreen` with `showOnboarding: false`)
- Added `test_speech_to_text_returns_unavailable_by_default` — asserts `available: false` when `STT_AVAILABLE` is False
- Added `test_speech_to_text_returns_available_when_flag_set` — asserts `available: true` when `STT_AVAILABLE` monkeypatched to True

### AI/ML Quality
- Added `STT_AVAILABLE` env-var flag (`ISHARA_STT_AVAILABLE=true`) to mark server-side Whisper availability
- `/speech-to-text` endpoint now returns clean `{"text": "", "available": false}` by default; returns `{"text": "", "available": true}` when flag is set — Flutter client should check `available` before presenting server STT as an option
- Cleared misleading placeholder text from stub response

### Documentation
- Flutter tests: **233 total** (up from 232); Backend tests: **83** (up from 81); Total: **316**

---

## [2.8.0] — Fix Cycle 24

### Product/UX
- Added first-launch onboarding wizard (`OnboardingScreen`) — 4-page swipeable introduction covering sign language interpretation, conversation mode, emergency SOS, and server setup
- `main.dart` reads `SharedPreferences['ishara_onboarded']` on startup; shows `OnboardingScreen` on first run, `HomeScreen` on subsequent runs
- Skip button allows users to bypass the wizard at any point

### Accessibility
- `home_screen.dart` search `TextField` wrapped in `Semantics(label: 'Search signs and phrases', textField: true)` — persistent label even after typing starts
- `sign_dictionary_screen.dart` search `TextField` wrapped in `Semantics(label: 'Search signs and phrases', textField: true)`
- `world_reader_screen.dart` question `TextField` wrapped in `Semantics(label: 'Ask a question about the scene', textField: true)`

### Reliability
- `settings_screen.dart` `_loadSavedSettings` now displays clamped port value: `savedPort.clamp(1, 65535).toString()` — UI matches the validated value

### Testing
- Added `test/screens/onboarding_screen_test.dart` (5 tests): renders first page, Skip present, Next advances page, last page shows Get Started, onboarding shows when not onboarded
- Added settings port clamp tests: port 0 → displays "1"; port 99999 → displays "65535"
- Flutter tests: **232 total** (up from 225); Backend tests: **81**; Total: **313**

---

## [2.7.0] — Fix Cycle 23

### Accessibility
- `AiChatScreen` chat `TextField` wrapped in `Semantics(label: 'Type your message', textField: true)` — screen readers now announce the input field consistently across all screens

### Reliability
- Settings screen port input clamped to valid range [1, 65535] via `_parsedPort()` helper — eliminates silent acceptance of invalid port values (0, 65536+)

### Security
- `_sanitize_user_input()` now uses `re.MULTILINE` flag so prompt-injection patterns starting after a newline (e.g. `\nSystem: override`) are also filtered

### Testing
- Added `test_circuit_breaker_half_open_probe_failure_reopens`: pre-sets circuit to half-open state, confirms that a probe `ConnectError` re-opens the circuit immediately
- Added `test_sanitize_strips_multiline_injection`: confirms multi-line payloads are sanitised
- Fixed `Operator:` Semantics label assertion to use `startsWith('Operator:')` — prevents false failures from trailing punctuation variation
- Backend tests: **81 total** (up from 79); Flutter tests: **225**; Total: **306**

---

## [2.6.0] — Fix Cycle 22

### Accessibility
- Emergency chat `TextField` Semantics label now uses `textField: true` property so the label is correctly recognised as a text-field by screen readers (TalkBack/VoiceOver)
- `EmergencyScreen` accepts `initialEmergencySent` constructor parameter enabling direct widget tests of active-emergency UI without triggering Geolocator/Vibration platform plugins

### Security
- `ISHARA_SIGN_LANGUAGE` env var sanitised by `_sanitize_user_input()` before interpolation into the LLM system prompt — closes the prompt-injection hygiene gap flagged in Cycles 19–21

### Reliability
- Circuit breaker half-open probe failure now immediately re-closes the circuit (fail count preset to `CIRCUIT_FAILURE_THRESHOLD - 1` before probe, so a single failure triggers re-open)

### Testing
- Rewrote `chat bubbles render with correct semantics labels` and `operator reply renders with correct Semantics label` tests to use `initialEmergencySent: true` — assertions now always execute (no more silent early-bail on missing platform plugins)
- Added `loadApiKey` happy-path test: `setApiKey('round-trip-key')` → `hasApiKeyInMemory == true`; clears → `hasApiKeyInMemory == false`
- Added `hasApiKeyInMemory` getter to `ApiService` for testability without `FlutterSecureStorage`
- Flutter tests: **225 total** (up from 224); Backend tests: **79 total**; Total: **304**

### Documentation
- `docs/AI_METRICS.md` Retry Behavior section updated with server-side circuit breaker description and interaction note with client-side retry layer

---

## [2.5.0] — Fix Cycle 21

### Accessibility
- Emergency chat `TextField` now has persistent `Semantics(label: 'Type your emergency message')` ancestor — TalkBack/VoiceOver announces the field label even while the user is typing

### Testing
- Added widget tests for Operator and Error Semantics labels in emergency chat bubbles
- Added backend tests: circuit breaker opens after threshold, fast-fail when open, `MAX_TEXT_LENGTH` guards on `/read-world` and `/evaluate-sign`
- Flutter tests: **224 total** (up from 223); Backend tests: **79 total** (up from 75); Total: **303**

### Security / Reliability
- Added `MAX_TEXT_LENGTH` (2000 chars) validation to `/read-world` question and `/evaluate-sign` target_sign — consistent with all other text endpoints
- Implemented Ollama circuit breaker: opens after 3 consecutive `ConnectError`s, fast-fails with 503 for 30 s, then half-opens for a probe; prevents 30 s × 2-retry latency when Ollama is persistently down
- Added `conftest.py` to reset circuit-breaker globals between backend tests

### Documentation
- Added `ISHARA_SIGN_LANGUAGE` env var to CONTRIBUTING.md production configuration table

---

## [2.4.0] — Fix Cycle 20

### Bug Fixes
- Emergency chat error detection: replaced fragile `startsWith('[')` heuristic with exact match against the single error string `'[Chat relay unavailable — call directly]'`, preventing user messages like `[my location]` from being incorrectly styled as errors
- Emergency chat bubble border-radius: left-aligned (operator/error) bubbles now have the correct "tail" on the `bottomLeft` corner (was incorrectly `bottomRight`)

### Accessibility
- Emergency chat messages now wrapped in `Semantics` with descriptive labels (`You: …`, `Operator: …`, `Error: …`) for TalkBack / VoiceOver users

### Code Quality
- `_REFUSAL_PATTERNS` moved from inside `emergency_message()` function body to module-level constant in `server.py`, eliminating redundant list allocation on every request

### Testing
- Added widget test verifying emergency chat bubble Semantics labels (`You: Help!`)
- Flutter tests: **223 total** (up from 222)
- Total: **298 tests** (223 Flutter + 75 backend)

---

## [2.3.0] — Fix Cycle 19

### Code Quality
- Added explanatory comments to the 2 remaining `GestureDetector` instances in `AiChatScreen` documenting why `InkWell` cannot replace them (keyboard-dismiss needs full-area tap; draggable input requires `onVerticalDragUpdate`)

### Testing
- Added `loadApiKey()` unit tests: verifies null return when no key stored, and graceful handling when FlutterSecureStorage unavailable
- Flutter tests: **222 total** (up from 220)

### Product / UX
- Emergency chat messages now render with distinct visual styles:
  - User messages: right-aligned, primary blue
  - Operator replies: left-aligned, surface colour
  - Error messages (e.g. `[Chat relay unavailable — call directly]`): left-aligned, warning amber border + background + ⚠️ icon

### Documentation
- Added docstring to `/classify-sound` endpoint — **all 7 key FastAPI endpoints** now have docstrings

---

## [Unreleased]

### Planned
- Multi-frame sign sequence interpretation (temporal context for motion signs)
- Streaming chat responses for reduced latency
- Offline sign dictionary (cached, no server required)
- RTL language support
- First-launch onboarding (server IP setup wizard)

---

## [2.2.0] — 2026-04-15 — Fix Cycle 18

### Code Quality
- `ApiService` factory: added doc-comment clarifying the singleton initialisation-only mutation pattern; marked with `// ignore: use_setters_to_change_properties` to make the intent explicit

### Product / UX
- Emergency chat now shows `[Chat relay unavailable — call directly]` when the backend is unreachable, replacing the silent swallow — users now know when the chat relay is down

### Documentation
- Added comprehensive docstrings to all 6 key FastAPI endpoints: `/interpret-sign`, `/emergency-message`, `/emergency-chat`, `/chat`, `/read-world`, `/evaluate-sign`

---

## [2.1.0] — 2026-04-15 — Fix Cycle 17

### Accessibility (Critical Regression Fix)
- Converted all remaining interactive `GestureDetector` widgets to `InkWell` across all screens:
  - `SignDictionaryScreen`: back button, category chips, sign list items, category grid items
  - `WorldReaderScreen`: back button, read-aloud button, capture & read button
  - `AiChatScreen`: sign translation expand/collapse toggle, play/pause animation button, `_ControlButton` helper widget
  - `ConversationScreen`: send message button, microphone toggle, start/stop sign reading button
- Only 2 `GestureDetector` instances remain (both legitimate non-interactive uses):
  - Keyboard dismiss tap on the message area (`onTap: _focusNode.unfocus()`)
  - Draggable input widget (`onVerticalDragUpdate` — `InkWell` does not support drag gestures)

### Documentation
- Fixed `CONTRIBUTING.md` test baseline: updated from 294 → 295 tests

---

## [2.0.0] — 2026-04-15 — Fix Cycle 16

### Accessibility
- Replaced all `GestureDetector` interactive widgets in `HomeScreen` with `InkWell` (retry button, nav bar items, premium button, category list)
- Replaced all `GestureDetector` interactive widgets in `LearnSignsScreen` with `InkWell` (back button, category chips, prev/check/next buttons)
- Replaced all `GestureDetector` interactive widgets in `SoundAwarenessScreen` with `InkWell` (listening toggle, clear-alerts button, test-alert buttons)

### Security
- API key removed from `SharedPreferences` plaintext storage; now exclusively stored in `FlutterSecureStorage` — eliminates dual-storage plaintext leak
- Added `ApiService.loadApiKey()` to read API key solely from secure storage

### Code Quality
- Fixed `AppColors.success` color: `0xFF34A853` → `0xFF15803D` (Green-700, ~4.55:1 WCAG AA on white)
- Improved `_rate_store` pruning: now scans all IPs and removes any entries fully outside the rate-limit window (not just the requesting IP)

### Product / UX
- `EmergencyScreen` now tracks structured chat history (`_chatHistory`) and sends it to the backend on each message, enabling coherent multi-turn conversations
- `_sendChatMessage` in emergency screen wires to `ApiService.emergencyChat()` with proper context and history parameters
- `_reset()` in emergency screen clears `_chatHistory` alongside display messages

### AI / ML Quality
- `/emergency-chat` now explicitly uses `temperature=0.7` (was implicitly defaulting to 0.1 — too deterministic for empathetic conversation)

### Testing
- Added `More` to few-shot assertion in `test_interpret_sign_prompt_includes_few_shot_examples` — verifies all 5 example signs (Hello, Thank you, Water, More, No sign detected)
- Added `test_rate_store_empty_keys_pruned` — verifies stale IP keys are evicted after the window expires while fresh keys remain
- Backend tests: 75 total (up from 74), all passing
- Flutter tests: 220 total, all passing

### Documentation
- `CONTRIBUTING.md`: corrected `ISHARA_CORS_ORIGINS` default from `*` to the actual default (`http://localhost:8080,http://localhost:3000`)

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
