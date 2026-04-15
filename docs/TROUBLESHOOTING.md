# Ishara Troubleshooting Guide

## Table of Contents
1. [Camera Not Starting](#camera-not-starting)
2. [Server Offline / Cannot Connect](#server-offline--cannot-connect)
3. [Low Sign Recognition Accuracy](#low-sign-recognition-accuracy)
4. [Ollama / Model Not Responding](#ollama--model-not-responding)
5. [API Key Authentication Failures](#api-key-authentication-failures)
6. [Speech-to-Text Not Working](#speech-to-text-not-working)
7. [TTS (Text-to-Speech) Silent](#tts-text-to-speech-silent)
8. [Rate Limit Errors (429)](#rate-limit-errors-429)
9. [App Crashes on Launch](#app-crashes-on-launch)
10. [Slow Response Times](#slow-response-times)
11. [Emergency Message Fails](#emergency-message-fails)
12. [Android-Specific Issues](#android-specific-issues)

---

## Camera Not Starting

**Symptoms:** Black screen in conversation view, "Camera initialisation failed" SnackBar.

**Solutions:**
1. Grant camera permission: **Settings → Apps → Ishara → Permissions → Camera → Allow**.
2. Restart the app — another app may hold the camera lock.
3. If on emulator, enable the virtual camera in AVD settings.
4. Check for `MissingPluginException`: ensure `flutter pub get` was run after cloning.

---

## Server Offline / Cannot Connect

**Symptoms:** Orange "Server offline" banner on home screen, 503 responses.

**Solutions:**
1. Confirm the backend server is running:
   ```bash
   cd backend && source .venv/bin/activate
   uvicorn server:app --host 0.0.0.0 --port 8000
   ```
2. Ensure the phone and server are on the **same Wi-Fi network**.
3. Update the server IP in **Settings** (tap the settings icon on the home screen).
4. Verify the port is not blocked by a firewall:
   ```bash
   curl http://<server-ip>:8000/ping
   ```
5. If you see "Connection refused", check that `uvicorn` is bound to `0.0.0.0` (not `127.0.0.1`).

---

## Low Sign Recognition Accuracy

**Symptoms:** Signs are misidentified frequently; confidence scores below 50%.

**Solutions:**
1. **Lighting** — ensure the signing area is well-lit from the front. Avoid back-lighting.
2. **Background contrast** — use a plain, non-skin-coloured background.
3. **Distance** — keep hands within 0.5–1.5 m of the camera.
4. **Speed** — slow down; the app captures a single frame every 2 seconds.
5. **Submit corrections** — tap 👎 after wrong interpretations to send training feedback.
6. **Model quality** — if using a smaller Ollama model (< 7B), switch to `gemma4` (26B) for better vision accuracy:
   ```bash
   ISHARA_MODEL=gemma4 uvicorn server:app ...
   ```

---

## Ollama / Model Not Responding

**Symptoms:** 503 "Model unavailable" or very long response times (> 30 s timeout).

**Solutions:**
1. Verify Ollama is running:
   ```bash
   ollama list   # Should show gemma4
   ollama run gemma4 "hello"
   ```
2. Pull the model if missing:
   ```bash
   ollama pull gemma4
   ```
3. Check available RAM — Gemma4 (26B) needs ~20 GB; use a quantised variant on smaller machines.
4. Set the correct Ollama URL in `.env`:
   ```
   OLLAMA_URL=http://localhost:11434
   ```
5. Restart Ollama service:
   ```bash
   pkill ollama && ollama serve &
   ```

---

## API Key Authentication Failures

**Symptoms:** 401 "Missing or invalid API key" errors.

**Solutions:**
1. Ensure the app has the API key configured: go to **Settings → API Key**.
2. The server key is set via environment variable:
   ```bash
   export ISHARA_API_KEY=your-secret-key
   ```
3. If `ISHARA_API_KEY` is not set, authentication is disabled (development mode).
4. Keys are matched exactly — check for trailing spaces or newlines.

---

## Speech-to-Text Not Working

**Symptoms:** Microphone button does nothing; no text appears.

**Solutions:**
1. Grant microphone permission: **Settings → Apps → Ishara → Permissions → Microphone**.
2. Ensure `speech_to_text` package is supported on your Android version (≥ Android 6).
3. The device needs an active internet connection for on-device speech recognition bootstrap.
4. Check Bluetooth headset conflicts — disconnect and use the built-in mic.

---

## TTS (Text-to-Speech) Silent

**Symptoms:** Signs are interpreted but no audio plays.

**Solutions:**
1. Unmute system volume and increase media volume.
2. Go to **Settings → Accessibility → Text-to-Speech** and ensure a TTS engine is installed.
3. Install Google Text-to-Speech from the Play Store if missing.
4. Check that the app is not in silent mode: `flutter_tts` respects the system ringer profile.

---

## Rate Limit Errors (429)

**Symptoms:** "Rate limit exceeded" errors after rapid requests.

**Solutions:**
1. By default the limit is **30 requests per minute** per IP.
2. Reduce capture frequency in the app (currently every 2 seconds).
3. Increase the limit on the server for trusted deployments:
   ```bash
   export ISHARA_RATE_LIMIT=60
   ```
4. For multi-device scenarios, use Redis so rate limits are shared across workers (see `backend/README.md`).

---

## App Crashes on Launch

**Symptoms:** App immediately closes after splash screen.

**Solutions:**
1. Run `flutter analyze` and `flutter pub get` to catch dependency mismatches.
2. Check for missing `google-services.json` (not required for current build).
3. On older Android (< API 24), some plugins may not be compatible — target API 24+.
4. Check `adb logcat` for the crash stack trace:
   ```bash
   adb logcat | grep -i "ishara\|flutter\|fatal"
   ```

---

## Slow Response Times

**Symptoms:** Sign interpretation takes > 10 seconds.

**Solutions:**
1. Move the Ollama server closer to the device (same LAN, not VPN).
2. Use a quantised model: `ISHARA_MODEL=gemma4:latest-q4_K_M uvicorn server:app ...`.
3. Reduce image quality before sending (consider adding compression in `_captureAndInterpret`).
4. Check server CPU/GPU utilisation — use `ollama ps` to see if the model is loaded.
5. Enable GPU offloading in Ollama: `OLLAMA_NUM_GPU=1`.

---

## Emergency Message Fails

**Symptoms:** "Emergency message generation failed" error.

**Solutions:**
1. Grant location permission to the app.
2. Ensure `emergency_type` is one of: `medical`, `fire`, `police`, `natural_disaster`, `other`.
3. The server must be reachable at the time of the emergency — configure offline fallback messages in Settings.

---

## Android-Specific Issues

| Issue | Fix |
|-------|-----|
| `PlatformException: No implementation found for flutter_secure_storage` | Run `flutter pub get` and rebuild |
| Camera gives `ERROR_CAMERA_DEVICE` | Force-stop app, revoke and re-grant camera permission |
| `MissingPluginException` on speech | Hot restart with `flutter run` instead of hot reload |
| Network calls fail on Android 9+ | Add `android:usesCleartextTraffic="true"` in `AndroidManifest.xml` for HTTP (development only) |

---

## Getting Support

1. Check existing [GitHub Issues](https://github.com/Medialordofficial/Ishara/issues).
2. Run the diagnostic: `adb bugreport > ishara_bugreport.zip` and attach to your issue.
3. Include: device model, Android version, app version from `pubspec.yaml`, and Ollama model name.
