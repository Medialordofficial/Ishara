#!/usr/bin/env bash
# Deploys the Ishara backend bundle to a Hugging Face Space.
#
# Prerequisites:
#   1. Create a Space at https://huggingface.co/new-space
#      - SDK: Docker
#      - Hardware: any GPU SKU (T4 small is enough; L4/A10G are faster)
#      - Persistent storage: enable Small (~20 GB) so the model survives reboots
#   2. git clone git@hf.co:spaces/<your-username>/<your-space-name> ../ishara-space
#   3. Run this script from the ishara_app repo root:
#        ./huggingface_space/deploy.sh ../ishara-space
#
# It copies the Docker bundle + server.py into the Space repo, commits, and pushes.

set -euo pipefail

if [ "${1:-}" = "" ]; then
  echo "usage: $0 <path-to-cloned-hf-space>"
  exit 64
fi

SPACE_DIR="$1"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ ! -d "$SPACE_DIR/.git" ]; then
  echo "error: $SPACE_DIR is not a git repo. Did you clone the HF Space first?" >&2
  exit 65
fi

echo "[deploy] copying bundle from $REPO_ROOT/huggingface_space/ -> $SPACE_DIR/"
cp "$REPO_ROOT/huggingface_space/Dockerfile"       "$SPACE_DIR/"
cp "$REPO_ROOT/huggingface_space/entrypoint.sh"    "$SPACE_DIR/"
cp "$REPO_ROOT/huggingface_space/requirements.txt" "$SPACE_DIR/"
cp "$REPO_ROOT/huggingface_space/README.md"        "$SPACE_DIR/"
cp "$REPO_ROOT/backend/server.py"                  "$SPACE_DIR/"

cd "$SPACE_DIR"
git add Dockerfile entrypoint.sh requirements.txt README.md server.py
if git diff --cached --quiet; then
  echo "[deploy] no changes to push"
  exit 0
fi
git commit -m "deploy: ishara backend bundle"
git push
echo "[deploy] done. Watch the build at the Space's Settings -> Logs tab."
