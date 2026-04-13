<p align="center">
  <h1 align="center">🤟 Ishara</h1>
  <p align="center"><i>Every gesture, understood.</i></p>
</p>

<p align="center">
  <a href="#the-problem">Problem</a> •
  <a href="#the-solution">Solution</a> •
  <a href="#how-it-works">How It Works</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#demo">Demo</a>
</p>

---

## The Problem

**70 million** deaf people live in our world. Over **80%** live in developing countries. Most have **zero access** to sign language interpreters.

When a deaf person walks into a pharmacy, a police station, a hospital, or a government office — they cannot communicate. They get misdiagnosed, wrongly detained, denied services, and left behind. The cost of a professional sign language interpreter is $50–150/hour — completely out of reach for the vast majority.

> *A deaf woman in rural Kenya needs insulin. She walks into a pharmacy. She signs. The pharmacist stares. She points. He guesses wrong. She leaves without her medication.*

**This happens millions of times a day, in every country on Earth.**

## The Solution

**Ishara** (Swahili/Arabic for _"sign"_ or _"gesture"_) turns any Android phone into a real-time sign language interpreter — powered by **Gemma 4**, running **locally and offline**.

The deaf person signs into their phone camera. Ishara interprets the signs and speaks the translation aloud. The hearing person speaks back. Ishara converts their speech to text displayed on screen for the deaf person.

**Two people who couldn't communicate — now can. With one phone. No internet. No cost.**

## How It Works

```
┌─────────────────────────────────────────────────────┐
│                    ISHARA APP                        │
├────────────────────────┬────────────────────────────┤
│    👤 DEAF USER        │    👤 HEARING USER         │
│                        │                            │
│    📷 Signs into       │    🎤 Speaks naturally     │
│       phone camera     │                            │
│         ↓              │         ↓                  │
│    Gemma 4 Multimodal  │    Speech-to-Text          │
│    interprets signs    │    (Whisper)               │
│         ↓              │         ↓                  │
│    🔊 Speaks aloud     │    📱 Text displayed       │
│    for hearing person  │    for deaf user           │
└────────────────────────┴────────────────────────────┘
```

### Key Features

- **🤟 Sign Language Recognition** — Gemma 4's multimodal vision interprets hand signs from the camera in real-time
- **🔊 Voice Output** — Interpreted signs are spoken aloud for the hearing person via text-to-speech
- **🎤 Voice Input** — Hearing person speaks naturally; speech is transcribed and displayed for the deaf user
- **🏥 Context-Aware** — Function calling provides domain-specific vocabulary (medical, legal, civic) for accurate interpretation
- **🌍 Multilingual** — Supports multiple sign languages and spoken languages
- **📴 Offline-First** — Runs entirely on-device via Ollama. No internet required after setup
- **🔒 Private** — No data ever leaves the device. Critical for medical and legal conversations

## Gemma 4 Usage

Ishara leverages **four core capabilities** of Gemma 4:

| Capability | How Ishara Uses It |
|---|---|
| **Multimodal Vision** | Camera frames → sign language interpretation through visual reasoning |
| **Function Calling** | Context-specific tools (medical terms, legal vocabulary, civic forms) for grounded, accurate translations |
| **Multilingual Support** | Output in the hearing person's language; support for multiple sign language systems |
| **Edge Deployment** | Runs locally via Ollama — no cloud, no latency, no privacy risk |

## Tech Stack

| Component | Technology |
|---|---|
| Mobile App | Flutter (Android) |
| AI Model | Gemma 4 26B via Ollama |
| Sign Interpretation | Gemma 4 multimodal vision |
| Speech-to-Text | Whisper |
| Text-to-Speech | Device native TTS |
| Backend Bridge | FastAPI (local server) |
| Function Calling | Gemma 4 native tool use |

## Architecture

```
┌────────────────────┐       Local WiFi       ┌─────────────────────┐
│   ANDROID PHONE    │ ◄───────────────────► │   LOCAL SERVER      │
│   (Flutter App)    │                        │   (FastAPI)         │
│                    │                        │                     │
│  📷 Camera capture │ ── image frames ────► │  Ollama             │
│  🎤 Microphone     │ ── audio ──────────► │  Gemma 4 26B        │
│  📱 Chat UI        │ ◄── text/commands ─── │  Whisper            │
│  🔊 TTS Speaker    │                        │  Context Tools      │
└────────────────────┘                        └─────────────────────┘
```

> **For production:** The architecture supports a migration path to fully on-device inference using Gemma 4 E2B + LiteRT, eliminating the need for the local server entirely.

## Getting Started

### Prerequisites

- Flutter 3.x installed ([install guide](https://docs.flutter.dev/get-started/install))
- Ollama installed ([ollama.com](https://ollama.com))
- Android device or emulator
- Python 3.10+ (for backend server)

### 1. Clone the repo

```bash
git clone https://github.com/Medialordofficial/Ishara.git
cd Ishara
```

### 2. Set up Ollama + Gemma 4

```bash
# Install Ollama
brew install ollama    # macOS
# or visit https://ollama.com for other platforms

# Pull Gemma 4 model
ollama pull gemma4

# Start Ollama server
ollama serve
```

### 3. Start the backend

```bash
cd backend
pip install -r requirements.txt
python server.py
```

### 4. Run the Flutter app

```bash
cd ..
flutter pub get
flutter run
```

### 5. Connect your phone

Ensure your Android phone and laptop are on the same WiFi network. The app will auto-discover the local server.

## Demo

> 🎬 *Video demo coming soon*

### Scenario: At the Pharmacy

1. Deaf user opens Ishara and points camera at themselves
2. Signs: "I need insulin. My supply ran out."
3. Ishara interprets and speaks aloud to the pharmacist
4. Pharmacist says: "What dosage? 10 units or 20 units?"
5. Deaf user reads the question on screen
6. Signs: "20 units. Once a day."
7. Pharmacist understands. Transaction complete.

**Time: 30 seconds. Cost: Free. Lives changed: Immeasurable.**

## Impact

| Metric | Scale |
|---|---|
| Deaf population worldwide | 70,000,000 |
| In developing countries | 56,000,000 (80%) |
| With access to interpreters | < 2% |
| Cost of human interpreter | $50–150/hour |
| Cost of Ishara | **Free** |

## Hackathon Tracks

This project is submitted to the **Gemma 4 Good Hackathon** for:

- **Main Track** — Best overall project
- **Digital Equity & Inclusivity** — Breaking barriers through intuitive interfaces
- **Ollama Special Technology** — Gemma 4 running locally via Ollama

## Roadmap

- [x] Project scaffolding & architecture
- [ ] Camera capture + Gemma 4 sign interpretation pipeline
- [ ] Two-way communication (voice input for hearing user)
- [ ] Function calling for domain-specific context (medical, legal)
- [ ] Offline-first architecture
- [ ] UI polish & accessibility
- [ ] Demo video production
- [ ] Kaggle writeup

## Team

Built with ❤️ for the Gemma 4 Good Hackathon.

## License

This project is licensed under the Apache License 2.0 — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  <b>Ishara</b> — <i>Every gesture, understood.</i><br/>
  70 million people. Zero interpreters. One phone.
</p>
