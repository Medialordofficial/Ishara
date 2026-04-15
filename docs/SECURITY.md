# Ishara — Security Guide

## Threat Model

Ishara operates on a **local network** between a mobile device and a backend server. The primary security boundary is the WiFi network.

### Attack Surface
| Component | Threat | Mitigation |
|-----------|--------|------------|
| WiFi LAN | Network sniffing | Use HTTPS via reverse proxy (see below) |
| Backend API | Unauthorized access | Optional API key auth (`ISHARA_API_KEY`) |
| Backend API | DoS / abuse | Per-IP rate limiting (30 req/min) |
| LLM prompts | Prompt injection | Input sanitization before prompt construction |
| Image upload | Oversized payloads | 10 MB limit enforced server-side |
| Text input | Buffer overflow / abuse | 2000 char limit on all text inputs |
| Emergency type | Invalid values | Allowlist validation (`medical`, `police`, `fire`, `natural_disaster`, `other`) |
| Auth failures | Brute force | Logged with IP address for monitoring |

## HTTPS / TLS Setup

Ishara's FastAPI backend does **not** terminate TLS directly. For production or exposed deployments, use a reverse proxy:

### Caddy (Recommended — automatic HTTPS)
```bash
# /etc/caddy/Caddyfile
ishara.example.com {
    reverse_proxy localhost:8000
}

# Start Caddy
caddy run
```
Caddy automatically obtains and renews Let's Encrypt certificates.

### Nginx
```nginx
server {
    listen 443 ssl;
    server_name ishara.example.com;

    ssl_certificate /etc/letsencrypt/live/ishara.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ishara.example.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### When is HTTPS required?
| Deployment | HTTPS Required? | Reason |
|------------|-----------------|--------|
| Same machine (localhost) | No | Traffic never leaves the machine |
| Trusted home WiFi | Optional | Low risk, but defends against WiFi sniffing |
| Shared/public network | **Yes** | Traffic can be intercepted |
| Internet-exposed | **Yes** | Mandatory for any public-facing deployment |

## API Key Authentication

```bash
# Set the API key (server side)
export ISHARA_API_KEY="your-secret-key-here"
python backend/server.py

# The Flutter app must include the key in requests
# (Configure in Settings → Server Connection)
```

**Key management:**
- Use a strong random key: `openssl rand -hex 32`
- Never commit keys to version control
- Rotate keys periodically
- Use environment variables or a secrets manager

## Rate Limiting

Default: **30 requests per IP per minute** (configurable via `ISHARA_RATE_LIMIT`).

Exempt paths (no rate limiting): `/ping`, `/health`, `/docs`, `/openapi.json`, `/redoc`

For production with multiple instances, replace the in-memory rate store with Redis:
```python
# Future: Redis-backed rate limiting
import redis
r = redis.Redis()
```

## Audit Logging

All security-relevant events are logged:
- `AUTH_FAIL ip=... path=...` — Failed authentication attempts
- `RATE_LIMIT ip=... path=...` — Rate limit exceeded
- `REQUEST ip=... method=... path=... status=...` — All API requests (non-health)

Forward logs to a monitoring system (ELK, Grafana/Loki, CloudWatch) for alerting.

## Prompt Injection Defense

User-provided text is sanitized before being included in LLM prompts:

**Filtered patterns:**
- `System:`, `Assistant:`, `Instruction:`, `Prompt:` prefix overrides
- "Ignore all previous instructions" / "Ignore prior prompts"
- "You are now a..." role override attempts
- "Forget everything" / "Forget your instructions"

**Sanitization approach:**
- Regex-based pattern matching (case-insensitive)
- Matched patterns replaced with `[filtered]`
- Applied to: chat messages, sound descriptions, world reader questions, emergency chat

**Limitations:**
- Best-effort defense; cannot prevent all adversarial inputs
- Primary safeguard: Gemma 4 runs locally, limiting blast radius to degraded output quality
- No external data exfiltration possible (model has no internet access)

## Data Privacy

| Data Type | Storage | Retention |
|-----------|---------|-----------|
| Camera frames | Memory only | Discarded after inference |
| Audio (mic) | Memory only | Not recorded; level-only |
| Chat history | In-memory | Lost on app restart |
| Settings (IP, theme) | SharedPreferences | Until cleared by user |
| Emergency messages | In-memory | Lost on app restart |
| Backend request logs | stdout | Server-defined retention |

**No persistent storage of user content.** All camera frames and audio data are processed in-memory and discarded.
