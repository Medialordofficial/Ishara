#!/usr/bin/env bash
# Ishara — One-shot focused retrain + side-by-side eval on Colab T4
# ==================================================================
# Run this as a single Colab cell:
#
#   !bash <(curl -s https://raw.githubusercontent.com/Medialordofficial/Ishara/main/training/colab_focused_retrain.sh)
#
# What it does:
#   1. Mounts Google Drive so the LoRA adapter survives session disconnects
#   2. Installs unsloth + deps
#   3. Pulls the latest training/eval scripts and ASL dataset from GitHub
#   4. Trains a FOCUSED LoRA (ASL JSON envelope only, 2 epochs, low LR)
#      -> saved to /content/drive/MyDrive/ishara-asl-gemma4-lora/
#   5. Runs the side-by-side eval (base vs fine-tuned) in two passes
#   6. Prints the resulting eval_report.md
#
# Total time on a fresh T4: ~25 min (3 min install + 5 min train + 17 min eval)

set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/Medialordofficial/Ishara/main"

echo "=========================================="
echo "[1/6] Mount Google Drive (for adapter persistence)"
echo "=========================================="
echo "NOTE: Drive must be mounted from a notebook cell BEFORE running this script."
echo "      In a separate cell run:"
echo "          from google.colab import drive; drive.mount('/content/drive')"
echo "      Otherwise the adapter saves to /content/training/ (lost on disconnect)."
if [ -d /content/drive/MyDrive ]; then
  echo "  ✓ /content/drive/MyDrive is present — adapter will persist"
else
  echo "  ⚠ Drive NOT mounted — adapter will go to /content/training/ (volatile)"
fi

echo
echo "=========================================="
echo "[2/6] Install unsloth + deps"
echo "=========================================="
pip install -q --upgrade unsloth unsloth_zoo

echo
echo "=========================================="
echo "[3/6] Pull latest training assets from GitHub"
echo "=========================================="
mkdir -p /content/training
cd /content/training
for f in train_unsloth.py eval_compare.py asl_dataset.jsonl; do
  rm -f "$f"
  wget -q "$REPO_RAW/training/$f"
  echo "  pulled $f"
done

echo
echo "=========================================="
echo "[4/6] Focused retrain (ASL JSON, 2 epochs, lr 1e-4)"
echo "=========================================="
export ISHARA_FOCUSED=1
# Adapter goes to Drive automatically because Drive is mounted
python /content/training/train_unsloth.py

echo
echo "=========================================="
echo "[5/6] Eval pass 1 (base) + pass 2 (fine-tuned)"
echo "=========================================="
# Point eval at the Drive adapter
export ISHARA_ADAPTER_DIR="/content/drive/MyDrive/ishara-asl-gemma4-lora"
rm -f /tmp/ishara_base_outputs.json /tmp/ishara_lora_outputs.json
python /content/training/eval_compare.py    # pass 1: base
python /content/training/eval_compare.py    # pass 2: fine-tuned + report

echo
echo "=========================================="
echo "[6/6] Side-by-side report"
echo "=========================================="
cat /content/eval_report.md
