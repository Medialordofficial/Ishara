# Ishara — User Guide

## What is Ishara?

Ishara is a mobile app that makes everyday communication easier for **deaf and hard-of-hearing** people. It uses AI (Google Gemma 4) running on your own computer — your data never leaves your network.

## Getting Started

### 1. Install the App
Install the APK on your Android device:
- Copy the APK file to your phone
- Open **Settings → Security → Allow unknown sources**
- Open the APK and tap **Install**

### 2. Set Up the Backend
Ishara needs a local server running Gemma 4 on your computer:

```bash
# Install Ollama (https://ollama.ai)
curl -fsSL https://ollama.ai/install.sh | sh

# Download the Gemma 4 model
ollama pull gemma4

# Start the Ishara backend
cd backend
pip install -r requirements.txt
python server.py
```

### 3. Connect the App
1. Open Ishara on your phone
2. Go to **Settings** (bottom nav → gear icon)
3. Enter your computer's **local IP address** and port (default: 8000)
4. Tap **Connect** — a green status indicator confirms connection

> **Tip**: Find your local IP with `ifconfig` (macOS/Linux) or `ipconfig` (Windows). Both devices must be on the same WiFi network.

## App Modes

### 🤝 Sign Language Conversation
Real-time sign language interpretation using your camera.
1. Tap **Start Conversation** on the home screen
2. Point your camera at the person signing
3. The app detects hand poses on-device and sends frames to Gemma 4 for interpretation
4. Translated text appears in the chat and is spoken aloud via text-to-speech

### 🔊 Sound Awareness
Ambient sound monitoring with visual + haptic alerts.
1. Tap **Sound Awareness** on the home screen
2. Grant microphone permission when prompted
3. The app continuously monitors sound levels
4. When sounds cross thresholds (75 dB warning, 90 dB critical), you get:
   - **Visual flash** on screen
   - **Haptic vibration** pattern
   - **Notification** with sound classification
   - **Screen reader announcement** for TalkBack users

### 🆘 Emergency SOS
Text-based emergency communication.
1. Tap **Emergency SOS** on the home screen
2. Select emergency type: **Medical**, **Police**, **Fire**, or **Natural Disaster**
3. Confirm the alert in the dialog
4. The app generates a message including your GPS location and that you communicate via text
5. Use the operator chat to text back and forth with help

### 🌍 World Reader
Point your camera at text, signs, or objects for AI descriptions.
1. Tap **World Reader** on the home screen
2. Point your camera at what you want to read
3. The AI describes text (menus, signs, labels), objects, and safety-relevant info
4. Optionally type a specific question about what you see

### 📖 Learn Signs
Practice sign language with AI feedback.
1. Tap **Learn Signs** on the home screen
2. Select a sign to practice from the dictionary
3. Perform the sign in front of your camera
4. Get immediate feedback on your hand position and gesture

### 📚 Sign Dictionary
Browse and search 100+ sign definitions.
1. Tap the **Search** tab in the bottom navigation
2. Browse by category or search by name
3. Each sign includes a description, emoji, and category

### 💬 AI Chat
General conversation with Ishara AI about accessibility, sign language, or anything else.
1. Tap **AI Chat** on the home screen
2. Type your message and tap send
3. The AI responds with accessible, supportive answers

## Settings

Access settings via the **gear icon** in the bottom navigation:

| Setting | Description |
|---------|-------------|
| Server Host | Your computer's local IP address |
| Server Port | Default: 8000 |
| Theme | System / Light / Dark |

## Troubleshooting

### App can't connect to server
- **Both devices on same WiFi?** The phone and computer must be on the same local network
- **Server running?** Run `python backend/server.py` and check for "Starting Ishara backend on port 8000"
- **Firewall blocking?** Ensure port 8000 is open on your computer
- **Correct IP?** Run `ifconfig | grep "inet "` (macOS) or `ipconfig` (Windows) to find your LAN IP

### Sign interpretation seems slow
- **Model loading**: First request after starting Ollama takes longer (model loads into VRAM)
- **Hardware**: Gemma 4 (26B) benefits from 16+ GB VRAM. Use a smaller model for faster results
- **Network**: WiFi latency on some routers can add delay

### Sound awareness not detecting sounds
- **Microphone permission**: Check Settings → Apps → Ishara → Permissions
- **Volume too low**: Sound thresholds start at 75 dB (normal conversation level)

### Camera not working
- **Camera permission**: Check Settings → Apps → Ishara → Permissions
- **Other apps**: Close other apps that might be using the camera

### Dark mode not saving
- **Restart**: Theme is persisted in SharedPreferences and loads on startup
- **Clear data**: If stuck, clear app data in Settings → Apps → Ishara → Clear Data

## Privacy & Data

- **No cloud**: All AI processing happens on your local network
- **No accounts**: No login, no personal data collected
- **No tracking**: No analytics, no crash reporting, no telemetry
- **Camera/mic**: Used only for real-time interpretation and sound awareness; frames are not stored
