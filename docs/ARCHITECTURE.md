# Ishara — Architecture Overview

## Design Philosophy

Ishara is a **privacy-first accessibility app** for deaf and hard-of-hearing users. All AI inference happens either on-device (Google ML Kit) or on the user's own hardware (Ollama). No data leaves the local network.

## System Architecture

```
┌──────────────────────────────┐
│     Flutter Mobile App       │
│  ┌────────────────────────┐  │
│  │   Screens (7 modes)    │  │
│  ├────────────────────────┤  │
│  │   Services Layer       │  │
│  │   - ApiService (HTTP)  │  │
│  │   - PoseDetection (ML) │  │
│  │   - TtsService         │  │
│  │   - NotificationService│  │
│  │   - ProgressService    │  │
│  ├────────────────────────┤  │
│  │  Google ML Kit (local) │  │
│  └────────────────────────┘  │
└──────────────┬───────────────┘
               │ HTTP (LAN)
               ▼
┌──────────────────────────────┐
│   FastAPI Backend (Python)   │
│   - Rate limiting            │
│   - API key auth (optional)  │
│   - Input validation         │
│   - Prompt engineering       │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│   Ollama + Gemma 4 (26B)    │
│   - Local LLM inference      │
│   - Multimodal (text+image)  │
└──────────────────────────────┘
```

## Key Design Decisions

### Why Gemma 4 via Ollama?
- **Privacy**: User conversations and images never leave the local network
- **Cost**: Zero API costs — runs on user's own hardware
- **Hackathon alignment**: Google AI hackathon requires Gemma integration
- **Multimodal**: Gemma 4 handles both text and image inputs natively

### Why On-Device Pose Detection (ML Kit)?
- **Latency**: Real-time 33-landmark detection at 30fps — sending every frame to the server would introduce unacceptable delay
- **Bandwidth**: Frame gating reduces backend API calls by ~70%
- **Offline resilience**: Pose analysis works without network; only interpretation requires the backend

### Why FastAPI Backend Instead of Direct Ollama Access?
- **Prompt engineering**: Custom system prompts per mode (interpreter, teacher, emergency responder)
- **Input validation**: Image size limits (10 MB), text length limits (2000 chars), emergency type allowlists
- **Security layer**: Rate limiting, optional API key auth, CORS controls
- **Abstraction**: App doesn't need to know Ollama API details; backend can swap models transparently

### Why SharedPreferences for State?
- **Simplicity**: No SQLite overhead for small key-value data (server IP, theme, streak counters)
- **Flutter standard**: Well-tested, cross-platform, zero setup
- **Appropriate scope**: User preferences and progress don't need relational queries

## Data Flow

### Sign Language Conversation
1. Camera captures frames continuously
2. ML Kit analyzes pose landmarks on-device
3. `PoseDetectionService` scores signing confidence (0–1.0)
4. Only when signing detected (> 0.3 threshold) does the app capture a frame
5. Frame sent to backend `/interpret-sign` endpoint
6. Backend formats multimodal prompt → Gemma 4 interprets the sign
7. AI response displayed in chat and announced via screen reader

### Sound Awareness
1. `NoiseMeter` records ambient decibel levels continuously
2. Levels compared against configurable thresholds (warning: 75 dB, critical: 90 dB)
3. Backend classifies sound description via `/classify-sound`
4. Multi-sensory alert: visual flash + haptic vibration + notification + screen reader announcement

### Emergency SOS
1. User selects emergency type (Medical / Police / Fire)
2. Confirmation dialog prevents accidental activation
3. GPS coordinates captured via `Geolocator`
4. Backend generates context-aware emergency message via Gemma 4
5. Message displayed, spoken aloud via TTS, and sent as notification
6. Operator chat provides text-to-speech relay for communicating with responders

## Project Structure

```
ishara_app/
├── lib/
│   ├── main.dart                  # App entry, theme setup
│   ├── screens/                   # 7 screen widgets
│   │   ├── home_screen.dart       # Main navigation hub
│   │   ├── conversation_screen.dart
│   │   ├── sound_awareness_screen.dart
│   │   ├── emergency_screen.dart
│   │   ├── world_reader_screen.dart
│   │   ├── learn_signs_screen.dart
│   │   ├── sign_dictionary_screen.dart
│   │   ├── ai_chat_screen.dart
│   │   └── settings_screen.dart
│   ├── services/                  # Business logic singletons
│   │   ├── api_service.dart       # HTTP client for backend
│   │   ├── pose_detection_service.dart  # ML Kit wrapper
│   │   ├── tts_service.dart       # Text-to-speech
│   │   ├── notification_service.dart
│   │   └── progress_service.dart  # Gamification/XP tracking
│   ├── models/                    # Data classes
│   │   ├── chat_message.dart
│   │   └── sound_alert.dart
│   ├── data/
│   │   └── sign_dictionary.dart   # 100+ sign definitions
│   └── utils/
│       ├── constants.dart         # Colors, strings, thresholds
│       └── theme.dart             # Light + dark themes
├── backend/
│   ├── server.py                  # FastAPI application
│   ├── test_server.py             # 18 pytest tests
│   └── README.md                  # Backend documentation
├── test/                          # 114 Flutter tests
│   ├── screens/                   # Widget tests for screens
│   ├── services/                  # Service unit tests
│   ├── models/                    # Model unit tests
│   ├── data/                      # Dictionary tests
│   └── utils/                     # Constants + theme tests
└── docs/
    └── ARCHITECTURE.md            # This file
```

## Testing Strategy

- **Unit tests**: Models, services, constants — verify business logic in isolation
- **Widget tests**: Screen rendering, navigation, user interactions
- **Backend tests**: HTTP endpoint validation, auth, rate limiting
- **Mock strategy**: `http.Client` injected into `ApiService` for testable HTTP calls; `SharedPreferences.setMockInitialValues` for storage

## Security Model

- **Network boundary**: All traffic stays on local WiFi (LAN)
- **Auth**: Optional API key via `ISHARA_API_KEY` environment variable
- **Rate limiting**: 30 requests/IP/minute (configurable via `ISHARA_RATE_LIMIT`)
- **Input validation**: Image max 10 MB, text max 2000 chars, emergency type allowlist
- **No cloud dependencies**: Zero external API calls — fully self-hosted
