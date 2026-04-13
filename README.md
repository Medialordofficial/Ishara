<p align="center">
  <img src="assets/images/ishara_logo.png" alt="Ishara Logo" width="200"/>
  <h1 align="center">🤟 Ishara</h1>
  <p align="center"><b>Every gesture, understood. Every sound, felt. Every barrier, broken.</b></p>
  <p align="center"><i>AI-powered accessibility companion for the deaf community — built with Gemma 4</i></p>
</p>

<p align="center">
  <a href="#the-problem">Problem</a> •
  <a href="#the-solution">Solution</a> •
  <a href="#five-modes">Five Modes</a> •
  <a href="#gemma-4-usage">Gemma 4 Usage</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#demo">Demo</a>
</p>

---

## The Problem

**70 million** deaf people live in our world. Over **80%** live in developing countries. Most have **zero access** to sign language interpreters.

But the problem is far bigger than translation. A deaf person faces barriers **every single moment of every day** that hearing people never think about:

| Moment | What Happens |
|---|---|
| 🔥 Fire alarm goes off | They don't hear it. They could die. |
| 🏥 Doctor explains a diagnosis | They miss everything. |
| 📞 They need to call 911 | They can't make a voice call. |
| 💊 At the pharmacy | Wrong medication from miscommunication. |
| 👶 Baby cries at night | They don't wake up. |
| 🚪 Doorbell rings | They don't know someone's there. |
| 📋 Filling out a form | They can't read the fine print or ask for help. |
| 🚗 Car horn behind them | They don't hear it. |

> *A deaf woman in rural Kenya needs insulin. She walks into a pharmacy. She signs. The pharmacist stares. She points. He guesses wrong. She leaves without her medication.*
>
> *That night, the fire alarm goes off in her building. She sleeps through it.*

**This isn't a translation problem. It's a whole-life accessibility gap.**

## The Solution

**Ishara** (Swahili/Arabic for _"sign"_ or _"gesture"_) is not just a sign language translator. It's a **complete accessibility companion** that turns any Android phone into a deaf person's ears, voice, and bridge to the entire hearing world — powered by **Gemma 4**, running **locally and offline**.

**Five modes. One app. A life transformed.**

## Five Modes

### 🤟 Mode 1: Conversation

Two-way, real-time communication between a deaf and hearing person.

```
┌────────────────────────┬────────────────────────────┐
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

- Deaf user signs → Gemma 4 interprets → speaks aloud for hearing person
- Hearing person speaks → transcribed → displayed as text for deaf user
- Context-aware: medical, legal, and civic vocabulary via function calling
- Works offline. No internet required.

### 🔔 Mode 2: Sound Awareness

The phone becomes their ears. Microphone constantly listens for critical sounds and alerts via **vibration + visual flash**.

| Sound Detected | Alert |
|---|---|
| 🔥 Fire / smoke alarm | **RED FLASH + STRONG VIBRATE** — "Fire alarm detected!" |
| 🚨 Siren | **ORANGE FLASH** — "Emergency vehicle approaching" |
| 🚗 Car horn | **VIBRATE** — "Car horn — check surroundings" |
| 🚪 Doorbell / knocking | **BLUE FLASH** — "Someone is at your door" |
| 👶 Baby crying | **GENTLE VIBRATE** — "Baby is crying" |
| 📢 Name being called | **VIBRATE** — "Someone is calling your name" |
| 🐕 Dog barking | **VIBRATE** — "Dog barking nearby" |

Gemma 4's multimodal understanding classifies environmental audio in real-time, on-device. **This could literally save lives.**

### 🆘 Mode 3: Emergency SOS

One tap emergency assistance — because a deaf person can't call 911.

1. **One tap** → app activates emergency mode
2. **Gets GPS location** via function calling
3. **Generates a voice message**: _"This is an emergency call from a deaf person at [address]. They need [police/ambulance/fire]. Please send help immediately."_
4. **Calls emergency services** and plays the message
5. **Opens text chat** so the deaf person can communicate with the operator by typing
6. **Sends location** to emergency contacts simultaneously

Uses Gemma 4's **function calling** for location services, emergency routing, contact management, and context-aware message generation.

### 👁️ Mode 4: World Reader

Point the camera at anything in the real world — Ishara reads and explains it.

| Point At | What Ishara Does |
|---|---|
| 📋 A form or document | Reads it, explains it, helps fill it out |
| 💊 Medicine bottle | Reads label, explains dosage & warnings |
| 🍽️ Restaurant menu | Reads items and descriptions |
| 📣 Public notice board | Summarizes the announcement |
| 🏷️ Product label | Reads ingredients, price, details |
| ✉️ A letter or mail | Reads and summarizes the content |

Uses Gemma 4's **multimodal vision** — the same capability that powers sign interpretation, applied to the entire visual world. Critical for deaf people who also have literacy challenges.

### 📚 Mode 5: Learn Signs

**Doubles the user base** — hearing people can learn sign language to communicate with the deaf community.

- App shows a sign to learn (video + description)
- User attempts the sign on camera
- Gemma 4 evaluates their form: _"Almost! Keep your fingers straighter."_
- **Situation packs**: Medical signs, Emergency signs, Greetings, Family, Shopping
- **Gamified**: Daily streaks, levels, achievements
- Builds empathy and bridges the communication gap **from both sides**

---

## Gemma 4 Usage

Ishara leverages **every core capability** of Gemma 4:

| Capability | How Ishara Uses It |
|---|---|
| **Multimodal Vision** | Sign language interpretation from camera frames; World Reader document/label analysis |
| **Multimodal Audio** | Sound Awareness environmental audio classification |
| **Function Calling** | Emergency SOS (GPS, contacts, routing); domain-specific vocabulary tools; dosage calculators |
| **Multilingual Support** | Multiple sign languages + spoken languages; localized UI |
| **Edge Deployment** | Runs entirely via Ollama — no cloud, no latency, no privacy risk |

## Tech Stack

| Component | Technology |
|---|---|
| Mobile App | Flutter (Android) |
| AI Model | Gemma 4 26B via Ollama |
| Sign Interpretation | Gemma 4 multimodal vision |
| Sound Classification | Gemma 4 multimodal audio |
| Speech-to-Text | Whisper |
| Text-to-Speech | Device native TTS |
| Backend Bridge | FastAPI (local server) |
| Function Calling | Gemma 4 native tool use |
| Emergency Services | Device telephony + Gemma 4 function calling |

## Architecture

```
┌──────────────────────┐       Local WiFi       ┌──────────────────────┐
│   ANDROID PHONE      │ ◄───────────────────► │   LOCAL SERVER       │
│   (Flutter App)      │                        │   (FastAPI + Ollama) │
│                      │                        │                      │
│  📷 Camera capture   │ ── image frames ────► │  Gemma 4 26B         │
│  🎤 Microphone       │ ── audio stream ───► │  ├─ Sign interpret    │
│  📱 5-Mode UI        │ ◄── text/commands ─── │  ├─ Sound classify    │
│  🔊 TTS Speaker      │                        │  ├─ World reading     │
│  📳 Haptic engine    │                        │  ├─ Function calling  │
│  📞 Emergency dialer │                        │  └─ Whisper STT       │
└──────────────────────┘                        └──────────────────────┘
```

> **Production path:** Full on-device inference using Gemma 4 E2B + LiteRT, eliminating the local server entirely. The phone becomes a fully standalone accessibility device.

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

### The 3-Minute Story

**0:00 — The Wake-Up Call**
A fire alarm blares in an apartment building. A deaf woman is sleeping. Her phone vibrates violently. Red screen: **"FIRE ALARM DETECTED."** She wakes up, grabs her child, gets out. *Ishara saved their lives.*

**0:30 — The Pharmacy**
She walks into a pharmacy. Signs into her phone: "I need insulin. My supply ran out." The pharmacist hears every word. Asks her a follow-up question. She reads it on screen. Signs her answer. Transaction complete. 30 seconds.

**1:15 — The Medicine**
Back home, she points her camera at the medicine bottle. Ishara reads: "Take 20 units once daily with food. Do not mix with alcohol. Store below 25°C." She understands everything.

**1:45 — The Emergency**
Her child falls. She taps the SOS button. One touch. Ishara calls emergency services: "This is an emergency from a deaf person at 14 Moi Avenue. A child is injured. Please send an ambulance." Help is on the way.

**2:15 — The Bridge**
Her hearing neighbor opens Ishara's Learn mode. Practices the sign for "Are you okay?" Gets feedback: "Perfect!" Walks over. Signs to her directly. She smiles. *The barrier is broken from both sides.*

**2:45 — Title Card**
_"Ishara — Every gesture, understood. Every sound, felt. Every barrier, broken."_
_70 million people. Five modes. One phone._

## Impact

| Metric | Scale |
|---|---|
| Deaf population worldwide | **70,000,000** |
| In developing countries | **56,000,000** (80%) |
| With access to interpreters | **< 2%** |
| Deaf people who miss emergency alarms | **Estimated 90%+** |
| Cost of human interpreter | $50–150/hour |
| Cost of Ishara | **Free** |

## Hackathon Tracks

This project is submitted to the **Gemma 4 Good Hackathon** for:

- 🏆 **Main Track** — Best overall project demonstrating exceptional vision, technical execution, and real-world impact
- 🌍 **Digital Equity & Inclusivity** — Breaking down barriers through linguistic diversity and intuitive interfaces
- 🖥️ **Ollama Special Technology** — Best project utilizing Gemma 4 running locally via Ollama

## Roadmap

- [x] Project scaffolding & architecture
- [x] Project branding & README
- [ ] Mode 1: Conversation — Camera + Gemma 4 sign interpretation pipeline
- [ ] Mode 1: Conversation — Voice input for hearing user (Whisper STT)
- [ ] Mode 2: Sound Awareness — Audio classification + haptic alerts
- [ ] Mode 3: Emergency SOS — One-tap emergency calling with auto-generated voice
- [ ] Mode 4: World Reader — Camera → document/label reading
- [ ] Mode 5: Learn Signs — Sign language learning with feedback
- [ ] Function calling — Domain-specific context tools (medical, legal)
- [ ] Offline-first architecture optimization
- [ ] UI polish & accessibility
- [ ] Demo video production
- [ ] Kaggle writeup

## Team

Built with ❤️ for the Gemma 4 Good Hackathon.

## License

This project is licensed under the Apache License 2.0 — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  <b>Ishara</b><br/>
  <i>Every gesture, understood. Every sound, felt. Every barrier, broken.</i><br/><br/>
  70 million people. Five modes. One phone.
</p>
