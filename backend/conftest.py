"""pytest configuration — resets global mutable state between tests."""
import pytest


@pytest.fixture(autouse=True)
def reset_circuit_breaker():
    """Reset the Ollama circuit-breaker state before every test.

    The circuit-breaker counters (_circuit_fail_count, _circuit_open_at) are
    module-level globals that can bleed between tests when a test triggers
    consecutive ConnectErrors.  This fixture ensures a clean slate.
    """
    import server
    server._circuit_fail_count = 0
    server._circuit_open_at = None
    yield
    server._circuit_fail_count = 0
    server._circuit_open_at = None
