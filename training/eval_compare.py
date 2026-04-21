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

    if adapter_dir is not None:
        adapter_path = Path(adapter_dir)
        if not adapter_path.exists():
            raise FileNotFoundError(
                f"LoRA adapter directory does not exist: {adapter_dir}\n"
                "The Colab session likely reset and wiped /content/. "
                "Retrain the adapter (run train_unsloth.py) before running pass 2."
            )
        if not (adapter_path / "adapter_config.json").exists():
            raise FileNotFoundError(
                f"{adapter_dir} exists but contains no adapter_config.json. "
                "This is not a valid PEFT/LoRA adapter directory."
            )
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


def free_model(model, tokenizer=None) -> None:
    import gc
    del model
    if tokenizer is not None:
        del tokenizer
    gc.collect()
    gc.collect()
    torch.cuda.empty_cache()
    try:
        torch.cuda.ipc_collect()
    except Exception:
        pass


def run_pass(
    prompts: list[str],
    adapter_dir: str | None,
    label: str,
    cache_file: Path | None = None,
) -> list[str]:
    """Run one pass over all prompts and return the outputs.

    If cache_file is given, write the partial outputs after every prompt
    so a Ctrl+C or disconnect doesn't lose work.
    """
    model, tokenizer = load_model_and_tokenizer(adapter_dir=adapter_dir)
    outputs: list[str] = []
    for i, p in enumerate(prompts, 1):
        print(f"\n[{i}/{len(prompts)}] {p}", flush=True)
        out = generate(model, tokenizer, p)
        outputs.append(out)
        print(f"{label} → {out[:200]}{'…' if len(out) > 200 else ''}", flush=True)
        if cache_file is not None:
            cache_file.write_text(json.dumps({"prompts": prompts[: len(outputs)], "outputs": outputs}))
    free_model(model, tokenizer)
    return outputs


def main() -> None:
    random.seed(0)
    prompts = HOLDOUT_PROMPTS[:NUM_PROMPTS]

    # Cache file lets us split runs across two python invocations so
    # the T4 VRAM is fully clean for each pass. Pass 1 writes it; pass 2
    # reads it and produces the final report.
    cache_file = Path("/tmp/ishara_base_outputs.json")
    only = os.getenv("ISHARA_ONLY", "").lower()  # "base" | "ishara" | ""

    def base_complete() -> bool:
        if not cache_file.exists():
            return False
        try:
            data = json.loads(cache_file.read_text())
            return data.get("prompts") == prompts and len(data.get("outputs", [])) == len(prompts)
        except Exception:
            return False

    # ---- Pass 1: BASE -------------------------------------------------
    if only in ("", "base") and not base_complete():
        print("=" * 60)
        print("Pass 1/2: BASE model")
        print("=" * 60)
        run_pass(prompts, adapter_dir=None, label="BASE", cache_file=cache_file)
        print(f"\n[saved base outputs to {cache_file}]")
        if only == "base":
            return
        print("\n" + "=" * 60)
        print("Base pass complete. Rerun the SAME command to do pass 2.")
        print("(Splitting into two python processes keeps T4 VRAM clean.)")
        print("=" * 60)
        return

    if not base_complete():
        raise SystemExit(
            f"Expected base outputs cache at {cache_file} but found nothing. "
            "Run pass 1 first (unset ISHARA_ONLY or set it to 'base')."
        )
    base_outputs = json.loads(cache_file.read_text())["outputs"]

    # ---- Pass 2: FINE-TUNED ------------------------------------------
    print("=" * 60)
    print("Pass 2/2: ISHARA fine-tuned model")
    print("=" * 60)
    ishara_cache = Path("/tmp/ishara_lora_outputs.json")
    ishara_outputs = run_pass(prompts, adapter_dir=ADAPTER_DIR, label="ISHARA", cache_file=ishara_cache)

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
