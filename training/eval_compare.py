"""
Ishara — Base vs Fine-Tuned Side-by-Side Evaluation
====================================================
Runs the same prompts through (a) the base Gemma 4 E4B model and
(b) the Ishara LoRA-tuned model, then prints both outputs so you can
judge whether the fine-tune actually helps deaf/non-speaking users.

Designed for Colab T4 — same hardware that trained the model.

Usage in a Colab cell
---------------------
    !python eval_compare.py

Optional environment variables
------------------------------
    ISHARA_BASE_MODEL    base model id (default: unsloth/gemma-4-E4B-it-unsloth-bnb-4bit)
    ISHARA_ADAPTER_DIR   path to LoRA adapter (default: /content/ishara-asl-gemma4-lora)
    ISHARA_NUM_PROMPTS   how many prompts to run (default: 10)
    ISHARA_OUT_FILE      where to save the side-by-side report (default: eval_report.md)
"""
from __future__ import annotations

import json
import os
import random
from pathlib import Path

import torch
from unsloth import FastLanguageModel
from unsloth.chat_templates import get_chat_template


BASE_MODEL = os.getenv(
    "ISHARA_BASE_MODEL",
    "unsloth/gemma-4-E4B-it-unsloth-bnb-4bit",
)
ADAPTER_DIR = os.getenv(
    "ISHARA_ADAPTER_DIR",
    "/content/ishara-asl-gemma4-lora",
)
NUM_PROMPTS = int(os.getenv("ISHARA_NUM_PROMPTS", "10"))
OUT_FILE = Path(os.getenv("ISHARA_OUT_FILE", "eval_report.md"))
MAX_NEW_TOKENS = 256


SYS_PROMPT = (
    "You are Ishara, an inclusive AI assistant for deaf and non-speaking "
    "users. You receive input as gesture descriptions, ASL-gloss style text, "
    "or partial/broken sentences. Never assume; ask clarifying questions when "
    "uncertain. Be patient, respectful, and concrete. Offer actionable help. "
    "Escalate urgency when you detect emergency signals."
)


# ── Hand-picked test prompts that exercise the fine-tune ─────────────────
# These are NOT in the training set. They mimic real deaf-user inputs and
# are the exact kind of thing a hackathon judge will type.

HOLDOUT_PROMPTS: list[str] = [
    # 1. Gesture description — should ask clarifying question, not guess wildly
    "[gesture] points at chest then makes squeezing motion with fist, breathing fast",

    # 2. ASL gloss — should parse the structure
    "[gloss] ME GO STORE YESTERDAY NO MONEY EMBARRASS",

    # 3. Partial text + emergency cue — should escalate
    "smoke kitchen alone scared what do",

    # 4. Pharmacy scenario — should produce a clerk-facing card
    "need medicine head hurt 3 day no sleep",

    # 5. Misunderstanding-prone short input — should NOT just guess
    "want red round bigger",

    # 6. Multi-intent — should sort and ask about time-locks
    "today doctor 2pm bank bread also",

    # 7. Emotional support — should validate before fixing
    "nobody understand me work meeting no caption again",

    # 8. Police interaction — high-stakes, requires safety-first response
    "police window car what do",

    # 9. Anaphylaxis — should immediately direct to EpiPen + SOS
    "[gloss] EAT NUT COOKIE THROAT TIGHT BREATH HARD",

    # 10. Workplace accommodation — should offer concrete email/draft
    "boss meeting tomorrow no caption again how say",

    # 11. Child medical — high-stakes parental fear
    "child fall hit head bleed scared",

    # 12. Restaurant allergy
    "menu allergy nut server how ask safe",
]


def load_model_and_tokenizer(adapter_dir: str | None):
    """Load base model + optional LoRA adapter."""
    model, tokenizer = FastLanguageModel.from_pretrained(
        model_name=BASE_MODEL,
        max_seq_length=1024,
        dtype=None,
        load_in_4bit=True,
    )
    tokenizer = get_chat_template(tokenizer, chat_template="gemma-3")

    if adapter_dir and Path(adapter_dir).exists():
        # PEFT-style adapter load
        from peft import PeftModel
        model = PeftModel.from_pretrained(model, adapter_dir)
        print(f"[loaded] base + LoRA adapter from {adapter_dir}")
    else:
        print(f"[loaded] base model only ({BASE_MODEL})")

    FastLanguageModel.for_inference(model)
    return model, tokenizer


def generate(model, tokenizer, user_prompt: str) -> str:
    msgs = [
        {"role": "system", "content": [{"type": "text", "text": SYS_PROMPT}]},
        {"role": "user", "content": [{"type": "text", "text": user_prompt}]},
    ]
    inputs = tokenizer.apply_chat_template(
        msgs,
        tokenize=True,
        return_tensors="pt",
        add_generation_prompt=True,
        return_dict=True,
    ).to(model.device)

    with torch.no_grad():
        out = model.generate(
            **inputs,
            max_new_tokens=MAX_NEW_TOKENS,
            do_sample=False,            # deterministic for fair comparison
            temperature=1.0,
            repetition_penalty=1.05,
            pad_token_id=tokenizer.pad_token_id or tokenizer.eos_token_id,
        )
    full = tokenizer.decode(out[0], skip_special_tokens=True)
    # strip the prompt prefix
    if SYS_PROMPT in full:
        full = full.split(SYS_PROMPT, 1)[-1]
    if user_prompt in full:
        full = full.split(user_prompt, 1)[-1]
    return full.strip()


def free_model(model) -> None:
    del model
    torch.cuda.empty_cache()


def main() -> None:
    random.seed(0)
    prompts = HOLDOUT_PROMPTS[:NUM_PROMPTS]
    print(f"Running {len(prompts)} prompts through BASE then ISHARA…\n")

    # ---- Pass 1: BASE -------------------------------------------------
    print("=" * 60)
    print("Pass 1/2: BASE model")
    print("=" * 60)
    model, tokenizer = load_model_and_tokenizer(adapter_dir=None)
    base_outputs: list[str] = []
    for i, p in enumerate(prompts, 1):
        print(f"\n[{i}/{len(prompts)}] {p}")
        out = generate(model, tokenizer, p)
        base_outputs.append(out)
        print(f"BASE → {out[:200]}{'…' if len(out) > 200 else ''}")
    free_model(model)

    # ---- Pass 2: FINE-TUNED ------------------------------------------
    print("\n" + "=" * 60)
    print("Pass 2/2: ISHARA fine-tuned model")
    print("=" * 60)
    model, tokenizer = load_model_and_tokenizer(adapter_dir=ADAPTER_DIR)
    ishara_outputs: list[str] = []
    for i, p in enumerate(prompts, 1):
        print(f"\n[{i}/{len(prompts)}] {p}")
        out = generate(model, tokenizer, p)
        ishara_outputs.append(out)
        print(f"ISHARA → {out[:200]}{'…' if len(out) > 200 else ''}")
    free_model(model)

    # ---- Write side-by-side report -----------------------------------
    lines = [
        "# Ishara — Base vs Fine-Tuned Side-by-Side\n",
        f"- Base model:  `{BASE_MODEL}`",
        f"- Adapter:     `{ADAPTER_DIR}`",
        f"- Prompts:     {len(prompts)} (held out from training)",
        f"- Decoding:    greedy (do_sample=False), max_new={MAX_NEW_TOKENS}\n",
        "---\n",
    ]
    for i, (p, b, ish) in enumerate(zip(prompts, base_outputs, ishara_outputs), 1):
        lines += [
            f"## Prompt {i}",
            f"```\n{p}\n```\n",
            "**BASE Gemma 4 E4B**",
            f"> {b.replace(chr(10), chr(10) + '> ')}\n",
            "**ISHARA fine-tuned**",
            f"> {ish.replace(chr(10), chr(10) + '> ')}\n",
            "---\n",
        ]
    OUT_FILE.write_text("\n".join(lines), encoding="utf-8")
    print(f"\n✅ Wrote side-by-side report to {OUT_FILE.resolve()}")
    print("\nReview the report. If ISHARA outputs are clearly more")
    print("deaf-aware (clarifying questions, clerk cards, escalation),")
    print("you are ready to ship. If not, retrain with more data + 2 epochs.")


if __name__ == "__main__":
    main()
