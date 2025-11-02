# 🚀 TTS Tool Deployment Guide

Comprehensive deployment documentation for the Text-to-Speech (TTS) Converter tool, covering local deployment, cloud platforms, and production environments.

## 📋 Table of Contents

- [Quick Start](#-quick-start)
- [Local Deployment](#-local-deployment)
  - [Docker Deployment](#docker-deployment)
  - [Python Virtual Environment](#python-virtual-environment)
  - [System Requirements](#system-requirements)
- [Cloud Deployment](#-cloud-deployment)
  - [Hugging Face Spaces](#hugging-face-spaces)
  - [Streamlit Cloud](#streamlit-cloud)
  - [Render](#render)
  - [Heroku](#heroku)
  - [AWS](#aws)
  - [Google Cloud Platform](#google-cloud-platform)
  - [Azure](#azure)
- [Platform-Specific Setup](#️-platform-specific-setup)
  - [Linux](#linux)
  - [Windows](#windows)
  - [macOS](#macos)
  - [Google Colab](#google-colab)
- [Environment Configuration](#️-environment-configuration)
- [Production Deployment](#️-production-deployment)
- [Troubleshooting](#-troubleshooting)
- [Performance Optimization](#️-performance-optimization)

## 🚀 Quick Start

### Docker (Recommended)
```bash
# Clone repository
git clone https://github.com/yourusername/tts-tool.git
cd tts-tool

# Build and run with Docker
docker build -t tts-tool .
docker run -p 7860:7860 tts-tool

# Access web interface
open http://localhost:7860
```

### Local Installation
```bash
# Clone repository
git clone https://github.com/yourusername/tts-tool.git
cd tts-tool

# Install dependencies
pip install -r requirements.txt

# Launch web interface
python main.py --web

# Access web interface
open http://localhost:7860
```

## 🏠 Local Deployment

### Docker Deployment

#### Prerequisites
- Docker installed (version 20.10+)
- Docker Compose (optional)

#### Option 1: Using Dockerfile
```bash
# Build the Docker image
docker build -t tts-tool:latest .

# Run the container
docker run -d \
  --name tts-app \
  -p 7860:7860 \
  -v $(pwd)/outputs:/app/outputs \
  -v $(pwd)/models_cache:/app/models_cache \
  tts-tool:latest

# View logs
docker logs -f tts-app

# Stop container
docker stop tts-app
docker rm tts-app
```

#### Option 2: Using Docker Compose
Create `docker-compose.yml`:
```yaml
version: '3.8'

services:
  tts-tool:
    build: .
    ports:
      - "7860:7860"
    volumes:
      - ./outputs:/app/outputs
      - ./models_cache:/app/models_cache
    environment:
      - TTS_DEVICE=cpu
      - TTS_CACHE_DIR=/app/models_cache
    restart: unless-stopped
    
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - tts-tool
    restart: unless-stopped
```

Run with Docker Compose:
```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

#### GPU Support
For GPU deployment:
```bash
# Build with NVIDIA runtime
docker build -f Dockerfile.gpu -t tts-tool:gpu .

# Run with GPU support
docker run --gpus all -p 7860:7860 tts-tool:gpu
```

### Python Virtual Environment

#### Option 1: Using venv
```bash
# Create virtual environment
python -m venv tts-env

# Activate virtual environment
# On Linux/macOS:
source tts-env/bin/activate
# On Windows:
tts-env\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Launch application
python main.py --web

# Deactivate when done
deactivate
```

#### Option 2: Using conda
```bash
# Create conda environment
conda create -n tts-tool python=3.10
conda activate tts-tool

# Install dependencies
pip install -r requirements.txt

# Launch application
python main.py --web
```

#### Option 3: Using pyenv (Linux/macOS)
```bash
# Install pyenv
curl https://pyenv.run | bash

# Install Python version
pyenv install 3.10.12
pyenv local 3.10.12

# Create virtual environment
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Launch application
python main.py --web
```

### System Requirements

#### Minimum Requirements
- **OS**: Linux, Windows 10+, macOS 10.14+
- **RAM**: 4GB (8GB recommended)
- **Storage**: 5GB free space
- **CPU**: 2+ cores
- **Python**: 3.8+ (3.10 recommended)

#### GPU Requirements (Optional)
- **GPU**: NVIDIA GPU with 6GB+ VRAM
- **CUDA**: 11.7+ or 12.0+
- **Driver**: NVIDIA Driver 515+

#### Audio System Dependencies
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y ffmpeg libasound2-dev portaudio19-dev

# CentOS/RHEL
sudo yum install -y alsa-utils-devel portaudio-devel ffmpeg

# macOS
brew install portaudio ffmpeg

# Windows (using Chocolatey)
choco install ffmpeg
```

## ☁️ Cloud Deployment

### Hugging Face Spaces

#### Method 1: Gradio Spaces
1. **Create Space**:
   ```bash
   # Install Hugging Face CLI
   pip install huggingface_hub
   
   # Login to Hugging Face
   huggingface-cli login
   
   # Create space
   huggingface-cli space create tts-tool
   ```

2. **Configure Space**: Create `space_id.txt` and `requirements.txt`:

   **space_id.txt**:
   ```
   tts-tool:latest
   ```

   **requirements.txt**:
   ```
   transformers>=4.35.0
   torch>=2.0.0
   torchaudio>=2.0.0
   gradio>=3.45.0
   datasets>=2.14.0
   librosa>=0.10.0
   pydub>=0.25.0
   ```

3. **Deploy Files**:
   ```bash
   # Copy your code to space
   cp main.py tts_tool/
   cp -r code/ tts_tool/
   cp requirements.txt tts_tool/
   
   # Push to space
   git push origin main
   ```

#### Method 2: Custom Dockerfile
Create `Dockerfile` for Space:
```dockerfile
FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libsndfile1 \
    libasound2-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Run application
CMD ["python", "main.py", "--web", "--port", "7860", "--host", "0.0.0.0"]
```

### Streamlit Cloud

1. **Install Streamlit**:
   ```bash
   pip install streamlit
   ```

2. **Create app.py**:
   ```python
   import streamlit as st
   from main import create_interface
   
   st.title("TTS Tool")
   st.write("Convert text to speech using AI models")
   
   # Create interface
   interface = create_interface("speecht5")
   
   # Launch interface in Streamlit
   interface.launch(server_port=8501, server_address="0.0.0.0")
   ```

3. **Deploy to Streamlit Cloud**:
   - Fork the repository to your GitHub
   - Visit [share.streamlit.io](https://share.streamlit.io)
   - Connect your GitHub account
   - Select repository and app.py
   - Deploy

### Render

1. **Create Web Service**:
   ```yaml
   # render.yaml
   services:
     - type: web
       name: tts-tool
       env: python
       buildCommand: pip install -r requirements.txt
       startCommand: python main.py --web --port $PORT
       envVars:
         - key: TTS_DEVICE
           value: cpu
   ```

2. **Deploy**:
   - Connect GitHub repository
   - Choose "Web Service"
   - Configure build settings
   - Deploy

### Heroku

1. **Install Heroku CLI** and login:
   ```bash
   heroku login
   ```

2. **Create Heroku App**:
   ```bash
   heroku create tts-tool-app
   ```

3. **Configure Procfile**:
   ```
   web: python main.py --web --port $PORT
   ```

4. **Deploy**:
   ```bash
   git add .
   git commit -m "Deploy to Heroku"
   git push heroku main
   ```

### AWS

#### EC2 Deployment
1. **Launch EC2 Instance**:
   - Choose Ubuntu 20.04+ AMI
   - Select t3.large or larger
   - Configure Security Group (port 7860)
   
2. **Setup Instance**:
   ```bash
   # Update system
   sudo apt update && sudo apt upgrade -y
   
   # Install dependencies
   sudo apt install -y python3.10 python3.10-venv ffmpeg
   
   # Clone repository
   git clone https://github.com/yourusername/tts-tool.git
   cd tts-tool
   
   # Setup environment
   python3.10 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   
   # Run with tmux
   tmux new -d -s tts-tool 'python main.py --web --host 0.0.0.0 --port 7860'
   ```

#### Elastic Beanstalk
1. **Install EB CLI**:
   ```bash
   pip install awsebcli
   ```

2. **Initialize Application**:
   ```bash
   eb init tts-tool
   eb create production
   eb deploy
   ```

#### AWS Lambda (Limited)
For simple deployments, consider containerized Lambda:
```dockerfile
FROM public.ecr.aws/lambda/python:3.10

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
CMD ["main.lambda_handler"]
```

### Google Cloud Platform

#### Cloud Run
1. **Build and Deploy**:
   ```bash
   # Build container
   gcloud builds submit --tag gcr.io/PROJECT-ID/tts-tool
   
   # Deploy to Cloud Run
   gcloud run deploy tts-tool \
     --image gcr.io/PROJECT-ID/tts-tool \
     --platform managed \
     --region us-central1 \
     --allow-unauthenticated
   ```

#### App Engine
Create `app.yaml`:
```yaml
runtime: python39

env_variables:
  TTS_DEVICE: cpu

automatic_scaling:
  min_instances: 0
  max_instances: 10

handlers:
  - url: /.*
    script: auto
```

### Azure

#### Container Instances
```bash
# Create resource group
az group create --name tts-rg --location eastus

# Create container
az container create \
  --resource-group tts-rg \
  --name tts-tool \
  --image your-registry/tts-tool:latest \
  --ports 7860 \
  --dns-name-label tts-tool-app
```

#### App Service
1. **Create App Service**:
   ```bash
   az webapp create \
     --resource-group tts-rg \
     --plan tts-plan \
     --name tts-tool-app \
     --runtime "PYTHON|3.10"
   ```

2. **Deploy**:
   ```bash
   zip -r app.zip .
   az webapp deployment source config-zip \
     --resource-group tts-rg \
     --name tts-tool-app \
     --src app.zip
   ```

## 🖥️ Platform-Specific Setup

### Linux

#### Ubuntu/Debian
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Python and dependencies
sudo apt install -y python3.10 python3.10-venv python3-pip \
    ffmpeg libasound2-dev portaudio19-dev git

# Install PyTorch (CPU version)
pip3 install torch torchaudio --index-url https://download.pytorch.org/whl/cpu

# Clone and setup project
git clone https://github.com/yourusername/tts-tool.git
cd tts-tool
python3.10 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Run application
python main.py --web
```

#### CentOS/RHEL
```bash
# Install dependencies
sudo yum groupinstall -y "Development Tools"
sudo yum install -y python3.10 python3-pip ffmpeg-devel alsa-utils-devel

# Install PyTorch
pip3 install torch torchaudio --index-url https://download.pytorch.org/whl/cpu

# Follow same setup as Ubuntu
```

#### Arch Linux
```bash
# Install dependencies
sudo pacman -S python python-pip ffmpeg alsa-utils portaudio git

# Follow same setup as Ubuntu
```

### Windows

#### Using PowerShell (Admin)
```powershell
# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install dependencies
choco install python ffmpeg git

# Restart terminal

# Setup project
git clone https://github.com/yourusername/tts-tool.git
cd tts-tool
python -m venv venv
venv\Scripts\Activate.ps1
pip install -r requirements.txt

# Run application
python main.py --web
```

#### Using Windows Subsystem for Linux (WSL)
```bash
# Install WSL2 with Ubuntu
wsl --install -d Ubuntu-22.04

# Follow Linux Ubuntu setup
```

### macOS

#### Using Homebrew
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install python3 ffmpeg portaudio git

# Setup project
git clone https://github.com/yourusername/tts-tool.git
cd tts-tool
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Run application
python main.py --web
```

#### Apple Silicon (M1/M2)
```bash
# Install PyTorch for Apple Silicon
pip install torch torchvision torchaudio

# Setup project (same as above)
```

### Google Colab

1. **Create Notebook**:
   ```python
   # Install dependencies
   !pip install transformers torch torchaudio gradio datasets
   !pip install librosa soundfile pydub
   
   # Clone repository
   !git clone https://github.com/yourusername/tts-tool.git
   %cd tts-tool
   
   # Download models
   from transformers import SpeechT5Processor, SpeechT5ForTextToSpeech
   processor = SpeechT5Processor.from_pretrained("microsoft/speecht5_tts")
   model = SpeechT5ForTextToSpeech.from_pretrained("microsoft/speecht5_tts")
   
   # Run application
   !python main.py --web
   ```

2. **Access Interface**: Use Colab's provided URL

## ⚙️ Environment Configuration

### Environment Variables

Create `.env` file:
```bash
# Core Settings
TTS_DEVICE=cpu
TTS_CACHE_DIR=./models_cache
TTS_MAX_TEXT_LENGTH=5000

# Web Interface
TTS_WEB_PORT=7860
TTS_WEB_HOST=0.0.0.0
TTS_WEB_SHARE=false

# Performance
TTS_WORKERS=4
TTS_BATCH_SIZE=8
TTS_MEMORY_LIMIT=8GB

# Models
TTS_DEFAULT_MODEL=speecht5
TTS_MODEL_CACHE_SIZE=3

# Logging
TTS_LOG_LEVEL=INFO
TTS_LOG_FILE=./logs/tts.log
```

### Configuration File

Create `config/deployment.yaml`:
```yaml
deployment:
  environment: production
  debug: false
  
web:
  host: "0.0.0.0"
  port: 7860
  share: false
  
models:
  default: "speecht5"
  cache_dir: "./models_cache"
  max_workers: 4
  
performance:
  memory_limit: "8GB"
  batch_size: 8
  
logging:
  level: "INFO"
  file: "./logs/deployment.log"
```

## 🏭 Production Deployment

### Using Supervisor
Create `/etc/supervisor/conf.d/tts-tool.conf`:
```ini
[program:tts-tool]
command=/path/to/venv/bin/python /path/to/tts-tool/main.py --web --host 0.0.0.0 --port 7860
directory=/path/to/tts-tool
user=tts-user
autostart=true
autorestart=true
stderr_logfile=/var/log/tts-tool/tts-tool.err.log
stdout_logfile=/var/log/tts-tool/tts-tool.out.log
environment=TTS_DEVICE="cpu",TTS_CACHE_DIR="/var/cache/tts-tool"
```

### Using systemd
Create `/etc/systemd/system/tts-tool.service`:
```ini
[Unit]
Description=TTS Tool Web Interface
After=network.target

[Service]
Type=simple
User=tts-user
WorkingDirectory=/path/to/tts-tool
ExecStart=/path/to/venv/bin/python main.py --web --host 0.0.0.0 --port 7860
Restart=always
RestartSec=10
Environment=TTS_DEVICE=cpu
Environment=TTS_CACHE_DIR=/var/cache/tts-tool

[Install]
WantedBy=multi-user.target
```

### Using PM2 (Node.js process manager for Python)
```bash
# Install PM2
npm install -g pm2

# Create ecosystem file
cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: 'tts-tool',
    script: 'main.py',
    interpreter: 'python3',
    args: '--web --host 0.0.0.0 --port 7860',
    cwd: '/path/to/tts-tool',
    env: {
      TTS_DEVICE: 'cpu',
      TTS_CACHE_DIR: '/var/cache/tts-tool'
    },
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '8G'
  }]
}
EOF

# Start application
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

## 🔧 Troubleshooting

### Common Issues

#### Model Download Fails
```bash
# Clear cache
rm -rf models_cache/

# Set cache directory with write permissions
export TTS_CACHE_DIR=/tmp/tts_cache

# Use verbose mode
python main.py --web --verbose
```

#### Audio Generation Errors
```bash
# Check audio system
arecord -l  # Linux
system_profiler SPAudioDataType  # macOS

# Install missing dependencies
sudo apt install -y portaudio19-dev libasound2-dev

# Test PyAudio
python -c "import pyaudio; print('PyAudio working')"
```

#### Memory Issues
```bash
# Use CPU instead of GPU
export TTS_DEVICE=cpu

# Reduce batch size
python main.py --batch texts.txt --workers 2

# Monitor memory usage
htop
```

#### Port Already in Use
```bash
# Find process using port
lsof -i :7860

# Kill process
kill -9 <PID>

# Use different port
python main.py --web --port 8080
```

### Performance Issues

#### Slow Generation
- Use GPU acceleration
- Reduce text length
- Optimize batch processing
- Check system resources

#### High Memory Usage
- Close unused applications
- Reduce batch size
- Use CPU mode
- Monitor memory with `htop`

### Docker Issues

#### Container Won't Start
```bash
# Check logs
docker logs tts-tool

# Check permissions
docker run --rm -it tts-tool ls -la /app

# Run with different user
docker run --user 1000:1000 -p 7860:7860 tts-tool
```

#### Out of Memory
```bash
# Limit memory usage
docker run -m 2g -p 7860:7860 tts-tool

# Use swap
docker run --memory-swap=4g -p 7860:7860 tts-tool
```

## ⚡ Performance Optimization

### GPU Acceleration
```bash
# Check GPU availability
nvidia-smi

# Use GPU for inference
python main.py --web --device cuda

# Optimize GPU memory
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512
```

### Batch Processing
```bash
# Increase workers for better throughput
python main.py --batch texts.txt --workers 8

# Optimize batch size
export TTS_BATCH_SIZE=16
```

### Caching
```bash
# Enable model caching
export TTS_CACHE_DIR=/fast/ssd/cache

# Pre-load models
python main.py --model speecht5 --warmup
```

### Web Server Optimization
```bash
# Use production WSGI server
pip install gunicorn

# Run with Gunicorn
gunicorn -w 4 -k uvicorn.workers.UvicornWorker main:app --bind 0.0.0.0:7860
```

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/tts-tool/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/tts-tool/discussions)
- **Documentation**: [Project Wiki](https://github.com/yourusername/tts-tool/wiki)
- **Discord**: [Community Server](https://discord.gg/example)

---

**Created with ❤️ by MiniMax Agent**
