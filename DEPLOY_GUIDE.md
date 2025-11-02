# 🚀 TTS Tool Deployment Guide

Step-by-step deployment instructions for the TTS Tool across various platforms and environments.

## 📋 Table of Contents

- [Pre-Deployment Checklist](#-pre-deployment-checklist)
- [Local Development Setup](#-local-development-setup)
- [Docker Deployment](#-docker-deployment)
- [GitHub Actions Setup](#️-github-actions-setup)
- [Hugging Face Spaces Deployment](#-hugging-face-spaces-deployment)
- [Streamlit Cloud Deployment](#-streamlit-cloud-deployment)
- [Render Deployment](#-render-deployment)
- [AWS Deployment](#-aws-deployment)
- [Google Cloud Platform](#-google-cloud-platform)
- [Heroku Deployment](#-heroku-deployment)
- [Production Deployment](#-production-deployment)
- [Troubleshooting](#️-troubleshooting)
- [Monitoring & Maintenance](#️-monitoring--maintenance)

## ✅ Pre-Deployment Checklist

### System Requirements
- [ ] Python 3.8+ installed
- [ ] Git installed
- [ ] Docker installed (for containerized deployment)
- [ ] 4GB+ RAM available
- [ ] 10GB+ storage available
- [ ] Internet connection for model downloads

### Code Preparation
- [ ] Clone repository: `git clone https://github.com/yourusername/tts-tool.git`
- [ ] Navigate to project: `cd tts-tool`
- [ ] Test local installation: `python main.py --web`
- [ ] Verify all tests pass: `pytest`
- [ ] Check web interface at `http://localhost:7860`

### Environment Setup
- [ ] Create virtual environment
- [ ] Install dependencies: `pip install -r requirements.txt`
- [ ] Set environment variables
- [ ] Configure cache directory
- [ ] Test basic functionality

## 🏠 Local Development Setup

### Method 1: Python Virtual Environment

#### Step 1: Create Virtual Environment
```bash
# Create project directory
mkdir tts-tool && cd tts-tool

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Linux/macOS:
source venv/bin/activate
# On Windows:
venv\Scripts\activate

# Verify activation
which python  # Linux/macOS
where python  # Windows
```

#### Step 2: Install Dependencies
```bash
# Upgrade pip
pip install --upgrade pip

# Install core dependencies
pip install -r requirements.txt

# Install development dependencies (optional)
pip install -r requirements-dev.txt

# Install in development mode
pip install -e .
```

#### Step 3: Test Installation
```bash
# Test basic import
python -c "from src.tts_tool import TTSProcessor; print('✅ Import successful')"

# Test CLI interface
python main.py --help

# Test web interface
python main.py --web --verbose

# Open browser to http://localhost:7860
```

### Method 2: Conda Environment

#### Step 1: Create Conda Environment
```bash
# Create environment
conda create -n tts-tool python=3.10

# Activate environment
conda activate tts-tool

# Verify Python version
python --version
```

#### Step 2: Install Dependencies
```bash
# Install PyTorch (CPU version)
conda install pytorch torchvision torchaudio cpuonly -c pytorch

# Install other dependencies
conda install -c conda-forge librosa soundfile pydub

# Install remaining packages with pip
pip install transformers datasets huggingface-hub gradio

# Install in development mode
pip install -e .
```

### Method 3: Pyenv (Linux/macOS)

#### Step 1: Install Pyenv
```bash
# Install pyenv
curl https://pyenv.run | bash

# Add to shell profile
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc

# Restart shell or source
source ~/.bashrc

# Install Python 3.10
pyenv install 3.10.12
```

#### Step 2: Setup Project
```bash
# Create local Python version
pyenv local 3.10.12

# Create virtual environment
python -m venv .venv

# Activate environment
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Test installation
python main.py --web
```

## 🐳 Docker Deployment

### Basic Docker Setup

#### Step 1: Create Dockerfile
Create `Dockerfile`:
```dockerfile
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libsndfile1 \
    libsndfile1-dev \
    libasound2-dev \
    portaudio19-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Install in development mode
RUN pip install -e .

# Create necessary directories
RUN mkdir -p outputs models_cache logs

# Expose port
EXPOSE 7860

# Set environment variables
ENV TTS_DEVICE=cpu
ENV TTS_CACHE_DIR=/app/models_cache
ENV TTS_WEB_PORT=7860
ENV TTS_WEB_HOST=0.0.0.0

# Run application
CMD ["python", "main.py", "--web", "--port", "7860", "--host", "0.0.0.0"]
```

#### Step 2: Build Docker Image
```bash
# Build image
docker build -t tts-tool:latest .

# Tag for registry (optional)
docker tag tts-tool:latest your-registry/tts-tool:latest

# Verify image
docker images | grep tts-tool
```

#### Step 3: Run Container
```bash
# Run container
docker run -d \
  --name tts-app \
  -p 7860:7860 \
  -v $(pwd)/outputs:/app/outputs \
  -v $(pwd)/models_cache:/app/models_cache \
  -v $(pwd)/logs:/app/logs \
  --restart unless-stopped \
  tts-tool:latest

# Check status
docker ps | grep tts-app

# View logs
docker logs -f tts-app

# Access web interface
open http://localhost:7860
```

### Docker Compose Setup

#### Step 1: Create docker-compose.yml
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
      - ./logs:/app/logs
      - ./config:/app/config
    environment:
      - TTS_DEVICE=cpu
      - TTS_CACHE_DIR=/app/models_cache
      - TTS_WEB_PORT=7860
      - TTS_WEB_HOST=0.0.0.0
      - TTS_LOG_LEVEL=INFO
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:7860"]
      interval: 30s
      timeout: 10s
      retries: 3

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - tts-tool
    restart: unless-stopped
```

#### Step 2: Create Nginx Configuration
Create `nginx.conf`:
```nginx
events {
    worker_connections 1024;
}

http {
    upstream tts_app {
        server tts-tool:7860;
    }

    server {
        listen 80;
        server_name localhost;

        location / {
            proxy_pass http://tts_app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # WebSocket support for Gradio
        location /queue/join {
            proxy_pass http://tts_app;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }
}
```

#### Step 3: Deploy with Docker Compose
```bash
# Start services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f tts-tool

# Access web interface
open http://localhost:7860

# Stop services
docker-compose down
```

### GPU-Enabled Docker

#### Step 1: Create GPU Dockerfile
Create `Dockerfile.gpu`:
```dockerfile
FROM nvidia/cuda:11.7-devel-ubuntu20.04

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-pip \
    python3.10-venv \
    ffmpeg \
    libsndfile1 \
    libasound2-dev \
    portaudio19-dev \
    && rm -rf /var/lib/apt/lists/*

# Create symlinks
RUN ln -s /usr/bin/python3.10 /usr/bin/python

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .
RUN pip install -e .

# Create directories
RUN mkdir -p outputs models_cache logs

# Expose port
EXPOSE 7860

# Set environment variables
ENV TTS_DEVICE=cuda
ENV TTS_CACHE_DIR=/app/models_cache
ENV TTS_WEB_PORT=7860
ENV TTS_WEB_HOST=0.0.0.0
ENV CUDA_VISIBLE_DEVICES=0

# Run application
CMD ["python", "main.py", "--web", "--port", "7860", "--host", "0.0.0.0"]
```

#### Step 2: Build and Run GPU Container
```bash
# Build GPU image
docker build -f Dockerfile.gpu -t tts-tool:gpu .

# Run with GPU support
docker run --gpus all \
  --name tts-app-gpu \
  -p 7860:7860 \
  -v $(pwd)/outputs:/app/outputs \
  -v $(pwd)/models_cache:/app/models_cache \
  -e TTS_DEVICE=cuda \
  tts-tool:gpu

# Verify GPU usage
docker exec -it tts-app-gpu nvidia-smi
```

## ⚙️ GitHub Actions Setup

### Step 1: Create GitHub Actions Workflow
Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy TTS Tool

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.10'
        
    - name: Cache pip dependencies
      uses: actions/cache@v3
      with:
        path: ~/.cache/pip
        key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
        
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install -r requirements-dev.txt
        
    - name: Run tests
      run: |
        pytest --cov=src/tts_tool --cov-report=xml
        
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml

  build-and-publish:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
      
    - name: Login to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
        
    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: |
          yourusername/tts-tool:latest
          yourusername/tts-tool:${{ github.sha }}
        cache-from: type=gha
        cache-to: type=gha,mode=max

  deploy-huggingface:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Deploy to Hugging Face Spaces
      uses: ./deploy-scripts/deploy-to-hf-spaces
      with:
        hf_token: ${{ secrets.HF_TOKEN }}
        space_id: yourusername/tts-tool
```

### Step 2: Configure Secrets
1. Go to your repository settings
2. Navigate to "Secrets and variables" → "Actions"
3. Add secrets:
   - `DOCKER_USERNAME`: Your Docker Hub username
   - `DOCKER_PASSWORD`: Your Docker Hub password
   - `HF_TOKEN`: Your Hugging Face token

### Step 3: Run CI/CD
```bash
# Push changes to trigger workflow
git add .
git commit -m "Add deployment workflow"
git push origin main

# Check workflow status in GitHub Actions tab
```

## 🤗 Hugging Face Spaces Deployment

### Method 1: Gradio Space

#### Step 1: Prepare Repository Structure
```
tts-tool/
├── app.py                 # Main Gradio app
├── requirements.txt       # Dependencies
├── README.md             # Space documentation
└── LICENSE               # License
```

#### Step 2: Create app.py
```python
import gradio as gr
import os
import sys

# Add src to path
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

from tts_tool import create_interface

# Create interface
interface = create_interface("speecht5")

# Configure for Spaces
interface.queue(
    max_size=32,
    concurrency_count=2,
    max concurrent users=4
).launch(
    server_name="0.0.0.0",
    server_port=7860,
    share=False,
    show_error=True
)
```

#### Step 3: Create Requirements.txt
```
transformers>=4.35.0
torch>=2.0.0
torchaudio>=2.0.0
gradio>=3.45.0
datasets>=2.14.0
huggingface-hub>=0.17.0
librosa>=0.10.0
soundfile>=0.12.0
pydub>=0.25.0
numpy>=1.24.0
pandas>=2.0.0
matplotlib>=3.7.0
tqdm>=4.65.0
scipy>=1.11.0
resampy>=0.4.0
```

#### Step 4: Deploy to Hugging Face
```bash
# Install Hugging Face CLI
pip install huggingface_hub

# Login to Hugging Face
huggingface-cli login

# Create Space
huggingface-cli space create tts-tool

# Copy files to Space
cp app.py requirements.txt README.md tts-tool/
cp -r src/ tts-tool/

# Commit and push
cd tts-tool
git add .
git commit -m "Initial commit for TTS Tool Space"
git push origin main
```

#### Step 5: Configure Space Settings
1. Visit your Space on Hugging Face
2. Go to "Settings" tab
3. Configure:
   - **Hardware**: Choose CPU/GPU type
   - **Visibility**: Public or Private
   - **SDK**: Gradio
   - **Python Version**: 3.10

### Method 2: Docker Space

#### Step 1: Create Dockerfile for Space
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

# Expose port
EXPOSE 7860

# Run application
CMD ["python", "app.py"]
```

#### Step 2: Create space_id.txt
```
tts-tool:latest
```

#### Step 3: Deploy Docker Space
```bash
# Build and push to Docker Hub
docker build -t yourusername/tts-tool:latest .
docker push yourusername/tts-tool:latest

# Update space_id.txt
echo "yourusername/tts-tool:latest" > space_id.txt

# Commit changes
git add space_id.txt Dockerfile app.py
git commit -m "Deploy as Docker Space"
git push origin main
```

## 🌐 Streamlit Cloud Deployment

### Step 1: Create Streamlit App
Create `app_streamlit.py`:
```python
import streamlit as st
import os
import sys

# Add src to path
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

from tts_tool import create_interface

st.title("🎤 TTS Tool")
st.markdown("Convert text to speech using AI models")

# Sidebar configuration
st.sidebar.header("Configuration")
model = st.sidebar.selectbox(
    "Select Model",
    ["speecht5", "mms_tts", "bark"],
    index=0
)

emotion = st.sidebar.selectbox(
    "Emotion",
    ["neutral", "happy", "sad", "excited", "whisper"],
    index=0
)

language = st.sidebar.selectbox(
    "Language",
    ["en", "fr", "de", "es", "it", "pt", "ru", "tr", "zh", "ja", "ko"],
    index=0
)

# Main interface
text_input = st.text_area(
    "Enter text to convert:",
    height=150,
    placeholder="Type your text here..."
)

col1, col2 = st.columns(2)

with col1:
    if st.button("🎵 Generate Speech", type="primary"):
        if text_input:
            with st.spinner("Generating speech..."):
                try:
                    from tts_tool import AdvancedTTSProcessor
                    processor = AdvancedTTSProcessor(model)
                    
                    output_path = f"output_{emotion}.wav"
                    if emotion != "neutral":
                        audio_file = processor.generate_with_emotion(
                            text_input, emotion, output_path
                        )
                    else:
                        audio_file = processor.generate_speech(
                            text_input, output_path
                        )
                    
                    st.success("✅ Speech generated successfully!")
                    st.audio(audio_file)
                    
                    # Download button
                    with open(audio_file, "rb") as f:
                        st.download_button(
                            "📥 Download Audio",
                            f.read(),
                            file_name=os.path.basename(audio_file),
                            mime="audio/wav"
                        )
                        
                except Exception as e:
                    st.error(f"❌ Error: {str(e)}")
        else:
            st.warning("⚠️ Please enter some text")

with col2:
    st.info("💡 **Tips:**")
    st.write("- Use short texts for faster generation")
    st.write("- Emotions work best with emotional content")
    st.write("- SpeechT5: Best for English")
    st.write("- MMS-TTS: Best for multiple languages")
    st.write("- Bark: Best for creative content")

# File upload for batch processing
st.header("📦 Batch Processing")
uploaded_file = st.file_uploader(
    "Upload text file (one text per line):",
    type=['txt']
)

if uploaded_file:
    texts = uploaded_file.read().decode("utf-8").splitlines()
    st.write(f"📝 Found {len(texts)} texts to process")
    
    if st.button("🚀 Start Batch Processing"):
        st.warning("Batch processing coming soon!")

# Footer
st.markdown("---")
st.markdown(
    "🚀 **TTS Tool** - Made with ❤️ by MiniMax Agent | "
    "📚 [Documentation](https://github.com/yourusername/tts-tool) | "
    "🐛 [Report Issues](https://github.com/yourusername/tts-tool/issues)"
)
```

### Step 2: Deploy to Streamlit Cloud
1. **Prepare Repository**:
   ```bash
   git clone https://github.com/yourusername/tts-tool.git
   cd tts-tool
   
   # Copy streamlit app
   cp app_streamlit.py streamlit_app.py
   ```

2. **Update requirements.txt**:
   ```
   streamlit>=1.28.0
   transformers>=4.35.0
   torch>=2.0.0
   torchaudio>=2.0.0
   datasets>=2.14.0
   huggingface-hub>=0.17.0
   librosa>=0.10.0
   soundfile>=0.12.0
   pydub>=0.25.0
   numpy>=1.24.0
   pandas>=2.0.0
   matplotlib>=3.7.0
   tqdm>=4.65.0
   scipy>=1.11.0
   resampy>=0.4.0
   ```

3. **Deploy**:
   - Visit [share.streamlit.io](https://share.streamlit.io)
   - Sign in with GitHub
   - Click "New app"
   - Select repository: `yourusername/tts-tool`
   - Select file: `streamlit_app.py`
   - Click "Deploy"

## ⚡ Render Deployment

### Step 1: Create render.yaml
Create `render.yaml`:
```yaml
services:
  - type: web
    name: tts-tool
    env: python
    plan: starter  # or 'standard' for better performance
    buildCommand: pip install -r requirements.txt
    startCommand: python main.py --web --port $PORT --host 0.0.0.0
    healthCheckPath: /
    envVars:
      - key: TTS_DEVICE
        value: cpu
      - key: TTS_CACHE_DIR
        value: /opt/render/project/src/models_cache
      - key: TTS_WEB_PORT
        value: $PORT
      - key: TTS_LOG_LEVEL
        value: INFO
    disk:
      name: tts-tool-cache
      mountPath: /opt/render/project/src/models_cache
      sizeGB: 10
```

### Step 2: Deploy to Render
1. **Connect Repository**:
   - Visit [render.com](https://render.com)
   - Sign up/login with GitHub
   - Click "New" → "Web Service"
   - Connect your repository

2. **Configure Service**:
   - **Name**: tts-tool
   - **Runtime**: Python 3
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `python main.py --web --port $PORT --host 0.0.0.0`
   - **Plan**: Select appropriate plan

3. **Environment Variables**:
   Add in Render dashboard:
   - `TTS_DEVICE`: cpu
   - `TTS_CACHE_DIR`: /opt/render/project/src/models_cache
   - `TTS_LOG_LEVEL`: INFO

4. **Deploy**:
   - Click "Create Web Service"
   - Wait for deployment to complete
   - Access your app at the provided URL

## ☁️ AWS Deployment

### EC2 Deployment

#### Step 1: Launch EC2 Instance
1. **Login to AWS Console**
2. **Navigate to EC2**
3. **Launch Instance**:
   - **AMI**: Ubuntu Server 20.04 LTS
   - **Instance Type**: t3.large (minimum)
   - **Key Pair**: Create or select existing
   - **Security Group**: Allow SSH (22), HTTP (80), HTTPS (443), Custom (7860)

#### Step 2: Setup Instance
```bash
# Connect to instance
ssh -i your-key.pem ubuntu@your-instance-ip

# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y python3.10 python3.10-pip python3.10-venv \
    git curl wget ffmpeg libasound2-dev portaudio19-dev \
    build-essential

# Clone repository
git clone https://github.com/yourusername/tts-tool.git
cd tts-tool

# Create virtual environment
python3.10 -m venv venv
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Create directories
mkdir -p outputs models_cache logs
```

#### Step 3: Run Application
```bash
# Set environment variables
export TTS_DEVICE=cpu
export TTS_CACHE_DIR=/home/ubuntu/tts-tool/models_cache
export TTS_WEB_PORT=7860
export TTS_WEB_HOST=0.0.0.0

# Run application with tmux
tmux new -d -s tts-tool 'python main.py --web --host 0.0.0.0 --port 7860'

# Verify it's running
tmux ls
ps aux | grep python

# Access web interface
# http://your-instance-ip:7860
```

### Elastic Beanstalk Deployment

#### Step 1: Install EB CLI
```bash
# Install EB CLI
pip install awsebcli

# Verify installation
eb --version
```

#### Step 2: Initialize Application
```bash
# Initialize Elastic Beanstalk
eb init

# Configuration:
# Region: us-east-1 (or your preferred region)
# Application name: tts-tool
# Platform: Python 3.10
# Use CodeCommit: No
# SSH access: Yes

# Create environment
eb create production

# Check status
eb status
```

#### Step 3: Deploy
```bash
# Deploy application
eb deploy

# Check application
eb health

# Open in browser
eb open
```

### ECS Deployment

#### Step 1: Create Dockerfile for ECS
```dockerfile
FROM public.ecr.aws/docker/library/python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libsndfile1 \
    libasound2-dev \
    portaudio19-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create directories
RUN mkdir -p outputs models_cache logs

# Expose port
EXPOSE 7860

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:7860 || exit 1

# Run application
CMD ["python", "main.py", "--web", "--port", "7860", "--host", "0.0.0.0"]
```

#### Step 2: Create task-definition.json
```json
{
  "family": "tts-tool",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "1024",
  "memory": "2048",
  "executionRoleArn": "arn:aws:iam::ACCOUNT:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::ACCOUNT:role/ecsTaskRole",
  "containerDefinitions": [
    {
      "name": "tts-tool",
      "image": "YOUR_ACCOUNT.dkr.ecr.REGION.amazonaws.com/tts-tool:latest",
      "portMappings": [
        {
          "containerPort": 7860,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "TTS_DEVICE",
          "value": "cpu"
        },
        {
          "name": "TTS_CACHE_DIR",
          "value": "/app/models_cache"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/tts-tool",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "memory": 1024,
      "memoryReservation": 512,
      "cpu": 512
    }
  ]
}
```

## ☁️ Google Cloud Platform

### Cloud Run Deployment

#### Step 1: Prepare for Cloud Run
```bash
# Install Google Cloud CLI
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Initialize gcloud
gcloud init

# Set project
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

#### Step 2: Deploy to Cloud Run
```bash
# Build and deploy
gcloud run deploy tts-tool \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 7860 \
  --memory 2Gi \
  --cpu 1 \
  --max-instances 10 \
  --set-env-vars TTS_DEVICE=cpu,TTS_CACHE_DIR=/tmp/models_cache

# Get service URL
gcloud run services describe tts-tool --region us-central1 --format 'value(status.url)'
```

### App Engine Deployment

#### Step 1: Create app.yaml
```yaml
runtime: python39

env_variables:
  TTS_DEVICE: cpu
  TTS_CACHE_DIR: /tmp/models_cache
  TTS_LOG_LEVEL: INFO

automatic_scaling:
  min_instances: 0
  max_instances: 10
  target_cpu_utilization: 0.6

resources:
  cpu: 2
  memory_gb: 4
  disk_size_gb: 10

handlers:
  - url: /.*
    script: auto
```

#### Step 2: Deploy to App Engine
```bash
# Deploy application
gcloud app deploy

# View application
gcloud app browse
```

## 🚀 Heroku Deployment

### Step 1: Setup Heroku
```bash
# Install Heroku CLI
# Visit: https://devcenter.heroku.com/articles/heroku-cli

# Login to Heroku
heroku login

# Create Heroku app
heroku create tts-tool-app

# Add buildpack
heroku buildpacks:set heroku/python
```

### Step 2: Create Heroku Files

#### Create Procfile
```
web: python main.py --web --port $PORT --host 0.0.0.0
```

#### Create runtime.txt
```
python-3.10.12
```

#### Update requirements.txt
```
# Core dependencies (include all necessary packages)
transformers>=4.35.0
torch>=2.0.0
torchaudio>=2.0.0
gradio>=3.45.0
datasets>=2.14.0
huggingface-hub>=0.17.0
librosa>=0.10.0
soundfile>=0.12.0
pydub>=0.25.0
numpy>=1.24.0
pandas>=2.0.0
matplotlib>=3.7.0
tqdm>=4.65.0
scipy>=1.11.0
resampy>=0.4.0
```

### Step 3: Configure Heroku Settings
```bash
# Set environment variables
heroku config:set TTS_DEVICE=cpu
heroku config:set TTS_CACHE_DIR=/tmp/models_cache
heroku config:set TTS_LOG_LEVEL=INFO

# Add Heroku Redis (for caching, optional)
heroku addons:create heroku-redis:mini

# Set buildpacks for system dependencies
heroku buildpacks:add --index 1 heroku/nodejs
```

### Step 4: Deploy
```bash
# Add files to git
git add .
git commit -m "Deploy to Heroku"

# Deploy to Heroku
git push heroku main

# Check logs
heroku logs --tail

# Open application
heroku open
```

## 🏭 Production Deployment

### Using Supervisor

#### Step 1: Install Supervisor
```bash
# Ubuntu/Debian
sudo apt install supervisor

# CentOS/RHEL
sudo yum install supervisor

# Start supervisor
sudo systemctl start supervisor
sudo systemctl enable supervisor
```

#### Step 2: Create Supervisor Configuration
Create `/etc/supervisor/conf.d/tts-tool.conf`:
```ini
[program:tts-tool]
command=/home/tts-user/tts-tool/venv/bin/python /home/tts-user/tts-tool/main.py --web --host 0.0.0.0 --port 7860
directory=/home/tts-user/tts-tool
user=tts-user
autostart=true
autorestart=true
stderr_logfile=/var/log/tts-tool/tts-tool.err.log
stdout_logfile=/var/log/tts-tool/tts-tool.out.log
stdout_logfile_maxbytes=50MB
stdout_logfile_backups=10
environment=TTS_DEVICE="cpu",TTS_CACHE_DIR="/var/cache/tts-tool",TTS_LOG_LEVEL="INFO"
stopsignal=TERM
stopwaitsecs=300
priority=10
```

#### Step 3: Setup Logging and Directories
```bash
# Create log directory
sudo mkdir -p /var/log/tts-tool
sudo chown tts-user:tts-user /var/log/tts-tool

# Create cache directory
sudo mkdir -p /var/cache/tts-tool
sudo chown tts-user:tts-user /var/cache/tts-tool

# Reload supervisor configuration
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start tts-tool

# Check status
sudo supervisorctl status
```

### Using systemd

#### Step 1: Create Systemd Service
Create `/etc/systemd/system/tts-tool.service`:
```ini
[Unit]
Description=TTS Tool Web Interface
Documentation=https://github.com/yourusername/tts-tool
After=network.target

[Service]
Type=simple
User=tts-tool
WorkingDirectory=/home/tts-tool/tts-tool
ExecStart=/home/tts-tool/tts-tool/venv/bin/python main.py --web --host 0.0.0.0 --port 7860
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=tts-tool
Environment=TTS_DEVICE=cpu
Environment=TTS_CACHE_DIR=/var/cache/tts-tool
Environment=TTS_LOG_LEVEL=INFO

# Security settings
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict
ProtectHome=yes
ReadWritePaths=/var/cache/tts-tool /home/tts-tool/tts-tool/outputs /var/log/tts-tool

[Install]
WantedBy=multi-user.target
```

#### Step 2: Setup and Start Service
```bash
# Create tts-tool user
sudo useradd --system --home /home/tts-tool --shell /bin/false tts-tool

# Setup application directory
sudo mkdir -p /home/tts-tool/tts-tool
sudo chown tts-tool:tts-tool /home/tts-tool

# Deploy application (as tts-tool user)
sudo -u tts-tool git clone https://github.com/yourusername/tts-tool.git /home/tts-tool/tts-tool
cd /home/tts-tool/tts-tool
sudo -u tts-tool python3.10 -m venv venv
sudo -u tts-tool venv/bin/pip install -r requirements.txt

# Create necessary directories
sudo -u tts-tool mkdir -p outputs models_cache logs

# Reload systemd and start service
sudo systemctl daemon-reload
sudo systemctl enable tts-tool
sudo systemctl start tts-tool

# Check status
sudo systemctl status tts-tool

# View logs
journalctl -u tts-tool -f
```

## 🔧 Troubleshooting

### Common Deployment Issues

#### Port Already in Use
```bash
# Find process using port
lsof -i :7860
netstat -tulpn | grep 7860

# Kill process
kill -9 <PID>

# Or use different port
python main.py --web --port 8080
```

#### Permission Denied
```bash
# Check file permissions
ls -la /var/cache/tts-tool

# Fix permissions
sudo chown -R tts-tool:tts-tool /var/cache/tts-tool
sudo chmod -R 755 /var/cache/tts-tool

# Check SELinux (CentOS/RHEL)
sudo setsebool -P httpd_can_network_connect 1
```

#### Memory Issues
```bash
# Check memory usage
free -h
ps aux --sort=-%mem | head

# Monitor memory
watch -n 1 'free -h'

# Reduce batch size
python main.py --batch texts.txt --workers 2

# Use swap
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

#### Model Download Issues
```bash
# Clear model cache
rm -rf models_cache/

# Check network connectivity
curl -I https://huggingface.co

# Use proxy if needed
export HTTP_PROXY=http://proxy.company.com:8080
export HTTPS_PROXY=http://proxy.company.com:8080

# Manual model download
python -c "from transformers import SpeechT5Processor; processor = SpeechT5Processor.from_pretrained('microsoft/speecht5_tts')"
```

#### Docker Issues
```bash
# Check Docker daemon
sudo systemctl status docker

# Check Docker logs
docker logs tts-tool

# Rebuild image
docker build --no-cache -t tts-tool .

# Run with different user
docker run --user 1000:1000 -p 7860:7860 tts-tool

# Check Docker resources
docker system df
docker system prune
```

### Performance Issues

#### Slow Generation
```bash
# Use GPU if available
python main.py --web --device cuda

# Reduce text length
export TTS_MAX_TEXT_LENGTH=1000

# Optimize batch processing
python main.py --batch texts.txt --workers 8

# Enable caching
export TTS_CACHE_DIR=/fast/ssd/cache
```

#### High CPU Usage
```bash
# Monitor CPU usage
top
htop

# Reduce workers
python main.py --batch texts.txt --workers 2

# Use CPU optimization
export TTS_DEVICE=mps  # macOS
export OMP_NUM_THREADS=4
```

### Network Issues

#### Firewall Blocking
```bash
# Check firewall status
sudo ufw status
sudo firewall-cmd --list-all

# Allow port
sudo ufw allow 7860
sudo firewall-cmd --add-port=7860/tcp --permanent

# Test port connectivity
telnet localhost 7860
```

#### SSL/HTTPS Issues
```bash
# Check SSL certificate
openssl s_client -connect your-domain.com:7860

# Use reverse proxy
# Configure nginx to handle SSL and proxy to application
```

## 📊 Monitoring & Maintenance

### Log Monitoring
```bash
# View application logs
tail -f /var/log/tts-tool/tts-tool.out.log

# System logs
journalctl -u tts-tool -f

# Docker logs
docker logs -f tts-tool

# Application-specific logs
tail -f logs/tts.log
```

### Health Checks
```bash
# Check application status
curl -f http://localhost:7860

# Automated health check script
#!/bin/bash
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:7860)
if [ $RESPONSE -ne 200 ]; then
    echo "TTS Tool is down! HTTP status: $RESPONSE"
    # Send alert or restart service
    systemctl restart tts-tool
fi
```

### Performance Monitoring
```bash
# Monitor system resources
htop
iotop
nethogs

# Application metrics
python -c "
from src.tts_tool import TTSProcessor
import psutil
print(f'CPU: {psutil.cpu_percent()}%')
print(f'Memory: {psutil.virtual_memory().percent}%')
print(f'Disk: {psutil.disk_usage(\"/\").percent}%')
"
```

### Backup and Recovery
```bash
# Backup model cache
tar -czf tts-cache-backup.tar.gz models_cache/

# Backup configurations
tar -czf tts-config-backup.tar.gz config/ .env

# Restore from backup
tar -xzf tts-cache-backup.tar.gz -C /var/cache/tts-tool/
```

### Update and Maintenance
```bash
# Update application
git pull origin main
pip install -r requirements.txt --upgrade
systemctl restart tts-tool

# Update system packages
sudo apt update && sudo apt upgrade -y

# Clean up old models
find models_cache/ -name "*.bin" -mtime +30 -delete

# Monitor disk usage
df -h
du -sh models_cache/
```

---

**Need help?** Check our [GitHub Issues](https://github.com/yourusername/tts-tool/issues) or [Discussions](https://github.com/yourusername/tts-tool/discussions) for support.

---

**Made with ❤️ by MiniMax Agent**
