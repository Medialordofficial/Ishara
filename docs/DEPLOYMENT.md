# Ishara Deployment Runbook

## Prerequisites

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| GPU | 8 GB VRAM | 16+ GB VRAM (RTX 3090/4090) |
| RAM | 16 GB | 32 GB |
| Storage | 20 GB free | 50 GB free |
| Python | 3.10+ | 3.12 |
| Flutter | 3.x | Latest stable |
| Ollama | 0.3+ | Latest |

## Step 1: Install Ollama

```bash
# macOS / Linux
curl -fsSL https://ollama.com/install.sh | sh

# Verify
ollama --version
```

## Step 2: Pull & Verify Model

```bash
ollama pull gemma4

# Verify model is available
ollama list | grep gemma4

# Quick test (should return text)
ollama run gemma4 "Say hello in one word"
```

## Step 3: Backend Setup

```bash
cd backend/

# Create virtual environment
python -m venv .venv
source .venv/bin/activate  # Linux/macOS
# .venv\Scripts\activate   # Windows

# Install dependencies
pip install -r requirements.txt

# Run tests
pytest test_server.py -v

# Start server
python server.py
# Or with uvicorn for production:
uvicorn server:app --host 0.0.0.0 --port 8000 --workers 2
```

## Step 4: Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OLLAMA_URL` | `http://localhost:11434` | Ollama API endpoint |
| `ISHARA_MODEL` | `gemma4` | Model name for inference |
| `ISHARA_API_KEY` | _(empty)_ | Set to enable API key auth |
| `ISHARA_RATE_LIMIT` | `30` | Max requests/minute per IP |
| `ISHARA_CORS_ORIGINS` | `*` | Comma-separated allowed origins |

```bash
# Example production configuration
export ISHARA_API_KEY="your-secure-random-key"
export ISHARA_RATE_LIMIT=60
export ISHARA_CORS_ORIGINS="http://192.168.1.100:8000"
```

## Step 5: Flutter App Build

```bash
# Get dependencies
flutter pub get

# Run tests
flutter test

# Build APK
flutter build apk --release

# Or build app bundle
flutter build appbundle --release
```

## Step 6: Configure App

In the app Settings tab:
1. Enter the server IP address (e.g., `192.168.1.100`)
2. Enter the port (default: `8000`)
3. Tap **Test Connection** — should show green checkmark
4. If using API key, enter it in the API Key field

## Step 7: HTTPS (Production)

### Option A: Caddy (Recommended — auto TLS)

```bash
# Install Caddy
sudo apt install -y caddy

# /etc/caddy/Caddyfile
ishara.yourdomain.com {
    reverse_proxy localhost:8000
}

sudo systemctl restart caddy
```

### Option B: Nginx + Let's Encrypt

```nginx
server {
    listen 443 ssl;
    server_name ishara.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/ishara.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ishara.yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
sudo certbot --nginx -d ishara.yourdomain.com
```

## Health Monitoring

### Manual Check
```bash
curl http://localhost:8000/health
# Expected: {"status":"ok","ollama":true,"model":"gemma4"}
```

### Systemd Service (Linux)

```ini
# /etc/systemd/system/ishara.service
[Unit]
Description=Ishara Backend
After=network.target ollama.service

[Service]
Type=simple
User=ishara
WorkingDirectory=/opt/ishara/backend
Environment=ISHARA_API_KEY=your-key
ExecStart=/opt/ishara/backend/.venv/bin/uvicorn server:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable ishara
sudo systemctl start ishara
sudo journalctl -u ishara -f  # View logs
```

### Cron Health Check

```bash
# Check every 5 minutes, restart if down
*/5 * * * * curl -sf http://localhost:8000/health || systemctl restart ishara
```

---

## Troubleshooting FAQ

### Backend won't start
- **`Cannot reach Ollama`**: Run `ollama serve` first, then start the backend
- **`Model not found`**: Run `ollama pull gemma4`
- **Port in use**: Check with `lsof -i :8000` and kill the process

### App can't connect to backend
- Ensure phone and server are on the **same Wi-Fi network**
- Check server IP: `hostname -I` (Linux) or `ifconfig | grep inet` (macOS)
- Verify firewall allows port 8000: `sudo ufw allow 8000/tcp`
- Test from phone browser: `http://<server-ip>:8000/ping`

### Ollama is slow / timing out
- Check GPU usage: `nvidia-smi` (NVIDIA) or `rocm-smi` (AMD)
- Reduce model size: `export ISHARA_MODEL=gemma4:2b` for faster inference
- Increase timeout: Backend uses 300s timeout by default
- Check disk space: Ollama models need ~15 GB

### Sign interpretation quality is poor
- Ensure good lighting (front-facing camera)
- Keep hands within the frame guide box
- Hold signs steady for 1-2 seconds
- Practice with simpler signs first (alphabet, greetings)

### App crashes on camera screen
- Grant camera permission in Android Settings → Apps → Ishara → Permissions
- If using emulator, camera features require a physical device

### Rate limit errors (429)
- Default: 30 requests/minute per IP
- Increase limit: `export ISHARA_RATE_LIMIT=60`
- Rate store resets on server restart

### Emergency SOS not working
- Requires GPS/location permission
- Emergency messages need backend connectivity
- Pre-generate messages when connected for offline use
