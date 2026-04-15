"""
Ishara Backend API tests.

Run with: pytest backend/test_server.py -v
"""

import os
import pytest
from fastapi.testclient import TestClient

# Disable auth for tests unless explicitly testing auth.
os.environ.pop("ISHARA_API_KEY", None)
# Point Ollama to a non-routable address so LLM calls fail fast.
os.environ["OLLAMA_URL"] = "http://127.0.0.1:1"

from server import app  # noqa: E402

client = TestClient(app)


# ─── Health & Ping ─────────────────────────────────────────


def test_ping_returns_ok():
    r = client.get("/ping")
    assert r.status_code == 200
    data = r.json()
    assert data["status"] == "ok"
    assert "model" in data


def test_health_returns_status():
    r = client.get("/health")
    assert r.status_code == 200
    data = r.json()
    assert "status" in data
    assert "ollama" in data
    assert "model" in data


# ─── Input Validation ──────────────────────────────────────


def test_classify_sound_requires_description():
    r = client.post("/classify-sound", json={})
    assert r.status_code == 422  # Pydantic validation


def test_emergency_message_invalid_type():
    r = client.post(
        "/emergency-message",
        json={"emergency_type": "zombie_apocalypse", "latitude": 0, "longitude": 0},
    )
    assert r.status_code == 400
    assert "Invalid emergency_type" in r.json()["detail"]


def test_emergency_message_valid_types():
    """Valid emergency types should pass validation (not return 400).
    With Ollama offline, we get 503 (not 400 = validation failure)."""
    r = client.post(
        "/emergency-message",
        json={"emergency_type": "medical", "latitude": 1.0, "longitude": 2.0},
    )
    # 200 (running) or 503 (offline), but NOT 400 (validation).
    assert r.status_code in (200, 503, 504)


def test_chat_message_too_long():
    r = client.post("/chat", json={"message": "x" * 2001})
    assert r.status_code == 400
    assert "too long" in r.json()["detail"].lower()


def test_emergency_chat_message_too_long():
    r = client.post("/emergency-chat", json={"message": "y" * 2001})
    assert r.status_code == 400
    assert "too long" in r.json()["detail"].lower()


def test_chat_accepts_valid_length():
    r = client.post("/chat", json={"message": "Hello"})
    # 200 or 503/504 depending on Ollama, but not 400/422.
    assert r.status_code in (200, 503, 504)


def test_interpret_sign_rejects_non_image():
    r = client.post(
        "/interpret-sign",
        files={"image": ("test.txt", b"not an image", "text/plain")},
    )
    assert r.status_code == 400
    assert "Unsupported image type" in r.json()["detail"]


def test_interpret_sign_rejects_oversized():
    # 11 MB of zeros
    data = b"\x00" * (11 * 1024 * 1024)
    r = client.post(
        "/interpret-sign",
        files={"image": ("big.jpg", data, "image/jpeg")},
    )
    assert r.status_code == 413
    assert "too large" in r.json()["detail"].lower()


# ─── Rate Limiting ─────────────────────────────────────────


def test_rate_limit_exempt_paths():
    """Ping and health are exempt from rate limiting."""
    for _ in range(40):
        r = client.get("/ping")
        assert r.status_code == 200


# ─── API Key Authentication ────────────────────────────────


def test_auth_disabled_by_default():
    """Without ISHARA_API_KEY env var, all requests pass."""
    r = client.get("/ping")
    assert r.status_code == 200


def test_auth_rejects_missing_key(monkeypatch):
    """When API key is set, requests without it are rejected."""
    from server import app as _app
    import server

    monkeypatch.setattr(server, "API_KEY", "test-secret-key")
    r = client.post("/classify-sound", json={"description": "loud bang"})
    assert r.status_code == 401
    assert "Invalid or missing API key" in r.json()["detail"]
    monkeypatch.setattr(server, "API_KEY", "")


def test_auth_accepts_valid_key(monkeypatch):
    """When API key is set, requests with correct key pass auth."""
    import server

    monkeypatch.setattr(server, "API_KEY", "test-secret-key")
    r = client.post(
        "/classify-sound",
        json={"description": "loud bang"},
        headers={"x-api-key": "test-secret-key"},
    )
    # Should pass auth (200 or 503 from Ollama, not 401).
    assert r.status_code != 401
    monkeypatch.setattr(server, "API_KEY", "")


def test_auth_rejects_wrong_key(monkeypatch):
    """When API key is set, requests with wrong key are rejected."""
    import server

    monkeypatch.setattr(server, "API_KEY", "test-secret-key")
    r = client.post(
        "/classify-sound",
        json={"description": "loud bang"},
        headers={"x-api-key": "wrong-key"},
    )
    assert r.status_code == 401
    monkeypatch.setattr(server, "API_KEY", "")


# ─── Endpoint Response Structure ───────────────────────────


def test_speech_to_text_placeholder():
    r = client.post("/speech-to-text", json={"audio_b64": "abc"})
    assert r.status_code == 200
    data = r.json()
    assert data["available"] is False
    assert "text" in data


def test_evaluate_sign_requires_image_and_target():
    r = client.post("/evaluate-sign")
    assert r.status_code == 422


def test_read_world_requires_image():
    r = client.post("/read-world")
    assert r.status_code == 422
