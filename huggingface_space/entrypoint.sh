#!/usr/bin/env bash
# Entrypoint for the Hugging Face Space container.
# Starts Ollama in the background, pulls the model on first run, then launches
# the FastAPI backend in the foreground on the port HF Spaces expects ($PORT).

set -euo pipefail

PORT="${PORT:-7860}"
OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
ISHARA_MODEL="${ISHARA_MODEL:-gemma4:latest}"
ISHARA_FAST_MODEL="${ISHARA_FAST_MODEL:-$ISHARA_MODEL}"
ISHARA_FULL_MODEL="${ISHARA_FULL_MODEL:-$ISHARA_MODEL}"

# Persist the model to HF Spaces' /data volume when persistent storage is on.
# Falls back to /root/.ollama (ephemeral) on free tiers.
if [ -d /data ] && [ -w /data ]; then
  export OLLAMA_MODELS="/data/ollama"
  mkdir -p "$OLLAMA_MODELS"
  echo "[entrypoint] using persistent model dir: $OLLAMA_MODELS"
fi

export OLLAMA_HOST
export ISHARA_MODEL
export ISHARA_FAST_MODEL
export ISHARA_FULL_MODEL
export OLLAMA_URL="http://$OLLAMA_HOST"

echo "[entrypoint] starting ollama serve on $OLLAMA_HOST"
ollama serve &
OLLAMA_PID=$!

# Wait for the Ollama HTTP API to come up.
for i in $(seq 1 60); do
  if curl -sf "http://$OLLAMA_HOST/api/tags" >/dev/null 2>&1; then
    echo "[entrypoint] ollama is up"
    break
  fi
  sleep 1
done

# Pull the model on first start (cached on persistent volume after that).
echo "[entrypoint] ensuring model $ISHARA_MODEL is available"
ollama pull "$ISHARA_MODEL"

# Hand off to uvicorn in the foreground so the Space stays alive.
echo "[entrypoint] starting uvicorn on 0.0.0.0:$PORT"
exec uvicorn server:app --host 0.0.0.0 --port "$PORT" --app-dir /app
