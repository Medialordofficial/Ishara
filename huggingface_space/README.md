---
title: Ishara Backend
emoji: 🤟
colorFrom: blue
colorTo: indigo
sdk: docker
app_port: 7860
pinned: true
short_description: Always-on Gemma 4 backend for the Ishara accessibility app
---

# Ishara Backend on Hugging Face Spaces

This Space hosts the Ishara FastAPI backend with **`gemma4:latest`** served by
Ollama on a GPU runtime, so the Flutter app has a stable always-on endpoint.

## What you get

- A fixed public URL like `https://<your-username>-ishara-backend.hf.space`
- All Ishara endpoints: `/health`, `/chat`, `/sign`, `/speech-to-text`,
  `/sound-classification`, `/emergency-message`, `/world-reader`,
  `/evaluate-sign`
- The model stays warm 24/7 — no cold-start hassle during the demo.

## One-time setup

1. Sign in at <https://huggingface.co> and create a new Space:
   - **SDK**: `Docker`
   - **Hardware**: pick a GPU SKU. `T4 small` is the cheapest that fits Gemma 4
     (~$0.60/hr while running). `L4` or `A10G` are faster.
   - **Persistent storage**: enable `Small` (~20 GB). Without this, every restart
     re-downloads the 10 GB model.
2. Copy the three files from this folder into the new Space repo:
   - `Dockerfile`
   - `entrypoint.sh`
   - `requirements.txt`
   - `server.py`  (copy from `../backend/server.py`)
   - `README.md`  (this file — keep the YAML frontmatter intact)
3. Optionally set Space **Secrets** for production hardening:
   - `ISHARA_API_KEY` — require this header on every request from the app
   - `ISHARA_RATE_LIMIT` — per-IP requests per minute (default 120)
4. Push. The first build will download Gemma 4 (~10 GB into `/data`) and start
   the FastAPI server. Subsequent restarts reuse the cached model.

A copy script that staples everything together:

```bash
# From the ishara_app repo root, after cloning your empty HF Space repo locally:
SPACE_DIR=../ishara-backend-space   # path to your cloned HF Space
cp huggingface_space/Dockerfile      "$SPACE_DIR/"
cp huggingface_space/entrypoint.sh   "$SPACE_DIR/"
cp huggingface_space/requirements.txt "$SPACE_DIR/"
cp huggingface_space/README.md       "$SPACE_DIR/"
cp backend/server.py                 "$SPACE_DIR/"
cd "$SPACE_DIR" && git add . && git commit -m "deploy" && git push
```

## Pointing the Flutter app at it

In the Ishara app → Settings, paste the Space URL into Host:

```
https://<your-username>-ishara-backend.hf.space
```

The app auto-detects HTTPS and uses port 443 — no other changes needed.

## Stop spending money

Pause the Space from the Hugging Face UI when you're not demoing. Persistent
storage is billed separately (~$0.01/GB/day) so the model stays cached even
while the GPU is paused.
