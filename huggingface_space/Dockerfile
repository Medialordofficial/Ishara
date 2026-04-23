# Hugging Face Space — Ishara backend with Ollama + Gemma 4
# Base on a CUDA image so the GPU SKUs (T4, A10G, L4...) work out of the box.
FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# System deps + Python.
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        python3 \
        python3-pip \
        zstd \
    && rm -rf /var/lib/apt/lists/*

# Install Ollama (the official installer drops the binary in /usr/local/bin).
RUN curl -fsSL https://ollama.com/install.sh | sh

WORKDIR /app

# Install backend Python deps first for better layer caching.
COPY requirements.txt /app/requirements.txt
RUN pip3 install --no-cache-dir -r /app/requirements.txt

# Application code.
COPY server.py /app/server.py
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# HF Spaces routes external traffic to whichever port the container exposes
# via app_port in README.md. We default to 7860 (HF default).
EXPOSE 7860

ENTRYPOINT ["/app/entrypoint.sh"]
