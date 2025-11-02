# ☁️ Cloud Deployment Guide

Complete guide for deploying your TTS Tool to various cloud platforms with step-by-step instructions, configuration options, and best practices.

## 🎯 Platform Overview

| Platform | Time | Difficulty | Cost | Best For | Pros | Cons |
|----------|------|------------|------|----------|------|------|
| **Hugging Face Spaces** | 5 min | Easy | Free | Quick demos, sharing | Easy setup, built-in CI/CD | Limited compute, public only |
| **Streamlit Cloud** | 10 min | Easy | Free | Python web apps | Simple, great for Streamlit | Limited to Streamlit apps |
| **Render.com** | 15 min | Easy | Free tier | Full-stack apps | Auto-deploy, databases | Cold starts, limited scaling |
| **Render.com Plus** | 20 min | Medium | $7+/mo | Production apps | Better performance, scaling | Paid service |
| **Railway** | 15 min | Easy | Pay-per-use | Quick deployments | Simple, auto-scaling | Limited free tier |
| **Vercel** | 10 min | Easy | Free tier | Frontend + functions | Global CDN, fast | Not ideal for Python apps |
| **DigitalOcean App Platform** | 30 min | Medium | $5+/mo | Scalable apps | Full control, databases | More configuration needed |
| **AWS/GCP/Azure** | 60 min | Advanced | Variable | Enterprise deployment | Complete control | Complex setup, monitoring needed |

## 🚀 Platform-Specific Guides

## 1. Hugging Face Spaces (Recommended for Quick Start)

### Prerequisites
- GitHub account
- Hugging Face account (free)
- Project files in GitHub repository

### Step-by-Step Deployment

#### Step 1: Prepare Repository
```bash
# Ensure your repository has the required Hugging Face configuration
cp deployment_configs/huggingface/* ./

# Verify files exist
ls -la app.py requirements.txt Dockerfile spaces.yml
```

#### Step 2: Create Space
1. Go to [Hugging Face Spaces](https://huggingface.co/spaces)
2. Click "Create new Space"
3. Fill in details:
   - **Space name**: `tts-tool` or `text-to-speech-converter`
   - **License**: `mit`
   - **Git LFS**: Enable (for large model files)
   - **Visibility**: Public
   - **SDK**: `Docker`
4. Click "Create a Space"

#### Step 3: Configure Space
Create `README.md` in your repository root:
```markdown
# TTS Tool Space

🤖 **Text-to-Speech Converter with multiple AI models**

This space provides:
- Multiple TTS models (SpeechT5, MMS-TTS, Bark)
- Real-time speech generation
- Batch processing
- Audio format conversion
- Web interface

## Usage
1. Enter text in the input field
2. Select TTS model and settings
3. Click "Generate Speech"
4. Play or download the audio

## Models Available
- **SpeechT5**: High-quality English TTS
- **MMS-TTS**: Multilingual support
- **Bark**: Creative TTS with emotions

---

Built with ❤️ using Hugging Face Spaces and Gradio
```

#### Step 4: Deploy Automatically
1. Push changes to GitHub: `git push origin main`
2. Hugging Face will automatically build and deploy
3. Monitor build logs at: `https://huggingface.co/spaces/yourusername/tts-tool/builds`
4. Access your space at: `https://huggingface.co/spaces/yourusername/tts-tool`

### Hugging Face Spaces Configuration

#### spaces.yml
```yaml
title: "TTS Tool"
description: "Advanced Text-to-Speech Converter"
sdk: docker
hardware: cpu-basic  # Options: cpu-basic, cpu-upgrade, gpu-small
pinned: false
suggested_memory_gb: 4
suggested_disk_space_gb: 10
sdk_version: 4.9.0
```

#### Dockerfile Optimization
```dockerfile
FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create cache directories
RUN mkdir -p models_cache logs

# Expose port
EXPOSE 7860

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:7860')" || exit 1

# Start application
CMD ["python", "main.py", "--web", "--port", "7860", "--host", "0.0.0.0"]
```

### Performance Optimization

#### Memory Management
```python
# Add to your main.py
import gc
import psutil
import os

def check_memory():
    """Monitor memory usage"""
    memory_percent = psutil.virtual_memory().percent
    if memory_percent > 80:
        print(f"⚠️ High memory usage: {memory_percent}%")
        gc.collect()
    return memory_percent

# Call in generation loop
check_memory()
```

#### Model Caching
```python
# Optimize model loading
from transformers import AutoModel, AutoTokenizer
import torch

# Use lazy loading
class OptimizedTTSModel:
    def __init__(self, model_name):
        self.model_name = model_name
        self.model = None
        self.tokenizer = None
    
    def load_model(self):
        if self.model is None:
            print(f"📥 Loading model: {self.model_name}")
            self.model = AutoModel.from_pretrained(self.model_name)
            self.tokenizer = AutoTokenizer.from_pretrained(self.model_name)
            # Move to appropriate device
            device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
            self.model.to(device)
```

## 2. Streamlit Cloud

### Prerequisites
- GitHub repository with Streamlit app
- Streamlit Cloud account (free)

### Step-by-Step Deployment

#### Step 1: Prepare Streamlit App
Create `streamlit_app.py`:
```python
# Copy from your Gradio interface
import streamlit as st
from tts_tool import TTSProcessor, AdvancedTTSProcessor
import torch
import tempfile
import os

st.set_page_config(
    page_title="TTS Tool",
    page_icon="🎤",
    layout="wide",
    initial_sidebar_state="expanded"
)

st.title("🎤 Text-to-Speech Converter")
st.markdown("Advanced TTS with multiple AI models")

# Sidebar settings
st.sidebar.header("⚙️ Settings")
model_name = st.sidebar.selectbox(
    "Select TTS Model",
    ["speecht5", "mms_tts", "bark"],
    index=0
)

emotion = st.sidebar.selectbox(
    "Emotion",
    ["neutral", "happy", "sad", "excited", "whisper"],
    index=0
)

language = st.sidebar.text_input("Language", value="en")

# Initialize model
@st.cache_resource
def load_model(model):
    return AdvancedTTSProcessor(model)

try:
    processor = load_model(model_name)
except Exception as e:
    st.error(f"Error loading model: {str(e)}")
    st.stop()

# Main interface
text_input = st.text_area(
    "Enter text to convert to speech:",
    height=150,
    placeholder="Type your text here..."
)

col1, col2 = st.columns(2)

with col1:
    if st.button("🎤 Generate Speech", type="primary", disabled=not text_input):
        if text_input.strip():
            try:
                with st.spinner("Generating speech..."):
                    # Generate temporary file
                    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
                        tmp_path = tmp.name
                    
                    # Generate speech
                    output_file = processor.generate_with_emotion(
                        text_input, emotion, tmp_path
                    )
                    
                    if os.path.exists(output_file):
                        # Display audio player
                        with open(output_file, 'rb') as audio_file:
                            st.audio(audio_file.read(), format='audio/wav')
                        
                        # Download button
                        with open(output_file, 'rb') as f:
                            st.download_button(
                                "💾 Download Audio",
                                f,
                                file_name="generated_speech.wav",
                                mime="audio/wav"
                            )
                        
                        # Clean up
                        os.unlink(output_file)
                    else:
                        st.error("Failed to generate speech")
                        
            except Exception as e:
                st.error(f"Error: {str(e)}")

with col2:
    st.info("💡 Tips:")
    st.write("- Choose different emotions for varied output")
    st.write("- MMS-TTS supports multiple languages")
    st.write("- Bark creates most creative audio")

# Batch processing section
st.header("📦 Batch Processing")
st.markdown("Process multiple texts at once")

batch_texts = st.text_area(
    "Enter multiple texts (one per line):",
    height=100,
    placeholder="First sentence\nSecond sentence\nThird sentence"
)

if st.button("📦 Process Batch") and batch_texts.strip():
    texts = [line.strip() for line in batch_texts.split('\n') if line.strip()]
    st.write(f"Processing {len(texts)} texts...")
    
    # Process batch
    # (Implementation similar to single processing)
    
# Footer
st.markdown("---")
st.markdown("Built with ❤️ using Streamlit and Hugging Face Transformers")
```

#### Step 2: Configure Requirements
Create `requirements-streamlit.txt`:
```
streamlit>=1.28.0
transformers>=4.35.0
torch>=2.0.0
torchaudio>=2.0.0
librosa>=0.10.0
soundfile>=0.12.0
pydub>=0.25.0
numpy>=1.24.0
pandas>=2.0.0
matplotlib>=3.7.0
```

#### Step 3: Deploy to Streamlit Cloud
1. Go to [Streamlit Cloud](https://share.streamlit.io/)
2. Click "New app"
3. Connect your GitHub account
4. Select repository: `yourusername/tts-tool`
5. Select branch: `main`
6. Main file path: `streamlit_app.py`
7. Advanced settings:
   - Python version: `3.10`
   - Requirements file: `requirements-streamlit.txt`
8. Click "Deploy"

### Streamlit Cloud Tips

#### Memory Management
```python
# Add to streamlit_app.py
import streamlit as st

@st.cache_data
def clear_cache():
    """Clear model cache to free memory"""
    import gc
    gc.collect()
    return "Cache cleared"

# Add button to clear cache
if st.sidebar.button("🧹 Clear Cache"):
    clear_cache()
    st.sidebar.success("Cache cleared!")
```

#### Progress Tracking
```python
import streamlit as st
import time

def process_with_progress(items):
    """Process items with progress bar"""
    progress_bar = st.progress(0)
    status_text = st.empty()
    
    for i, item in enumerate(items):
        # Update progress
        progress = (i + 1) / len(items)
        progress_bar.progress(progress)
        status_text.text(f"Processing {i + 1}/{len(items)}")
        
        # Process item
        time.sleep(0.1)  # Simulate processing
    
    status_text.text("✅ Processing complete!")
```

## 3. Render.com

### Prerequisites
- GitHub account
- Render account (free)

### Step-by-Step Deployment

#### Step 1: Prepare for Render
Create `render.yaml`:
```yaml
services:
  - type: web
    name: tts-tool
    env: python
    plan: free  # or starter
    buildCommand: pip install -r requirements.txt
    startCommand: python main.py --web --port $PORT --host 0.0.0.0
    envVars:
      - key: PYTHON_VERSION
        value: 3.10.0
    scaling:
      minInstances: 1
      maxInstances: 1
```

Create `build.sh`:
```bash
#!/bin/bash
# Build script for Render

echo "🔨 Building TTS Tool for Render..."

# Install Python dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Create necessary directories
mkdir -p logs
mkdir -p models_cache

# Set permissions
chmod +x build.sh

echo "✅ Build complete!"
```

#### Step 2: Create Web Service
1. Go to [Render Dashboard](https://dashboard.render.com/)
2. Click "New" → "Web Service"
3. Connect your GitHub account
4. Select repository: `yourusername/tts-tool`
5. Configure service:
   - **Name**: `tts-tool`
   - **Region**: Choose closest region
   - **Branch**: `main`
   - **Root Directory**: Leave empty
   - **Runtime**: `Python 3`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `python main.py --web --port $PORT --host 0.0.0.0`
6. Click "Create Web Service"

#### Step 3: Configure Environment
1. Go to service settings
2. Add environment variables:
   ```
   TTS_DEVICE=cpu
   TTS_CACHE_DIR=/tmp/models_cache
   TTS_WEB_PORT=$PORT
   TTS_WEB_HOST=0.0.0.0
   ```
3. Scale settings:
   - **Instances**: 1 (free tier)
   - **Instance Type**: Free
   - **Auto-Deploy**: Enabled

### Render Deployment Tips

#### Performance Optimization
```python
# Optimize for Render environment
import os
import tempfile

# Use Render's ephemeral disk
CACHE_DIR = os.environ.get('RENDER_DISK_PATH', '/tmp/models_cache')
os.makedirs(CACHE_DIR, exist_ok=True)

# Use Render's PORT
PORT = int(os.environ.get('PORT', 8000))

# Add to main.py
def create_app():
    return main()  # Your main app function
```

#### Health Checks
```python
from flask import Flask, jsonify
import threading
import time

app = Flask(__name__)

@app.route('/health')
def health_check():
    return jsonify({
        'status': 'healthy',
        'service': 'tts-tool',
        'timestamp': time.time()
    })

@app.route('/')
def index():
    return "TTS Tool is running!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=PORT)
```

## 4. Railway

### Step-by-Step Deployment

#### Step 1: Prepare for Railway
Create `railway.json`:
```json
{
  "build": {
    "builder": "NIXPACKS",
    "buildCommand": "pip install -r requirements.txt"
  },
  "deploy": {
    "startCommand": "python main.py --web --port $PORT --host 0.0.0.0",
    "healthcheckPath": "/health",
    "healthcheckTimeout": 100,
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

#### Step 2: Deploy to Railway
1. Go to [Railway](https://railway.app/)
2. Click "Deploy Now" with GitHub OAuth
3. Select repository: `yourusername/tts-tool`
4. Configure service:
   - **Service Name**: `tts-tool`
   - **Branch**: `main`
   - **Root Directory**: Leave empty
5. Click "Deploy"

#### Step 3: Configure Service
1. Go to service dashboard
2. Settings → Variables:
   ```
   PORT=8000
   TTS_DEVICE=cpu
   TTS_CACHE_DIR=/tmp/models_cache
   ```
3. Settings → Networking:
   - **Public Networking**: Enabled
   - **Custom Domain**: Optional

## 5. DigitalOcean App Platform

### Step-by-Step Deployment

#### Step 1: Create App Specification
Create `.do/app.yaml`:
```yaml
name: tts-tool
services:
- name: web
  source_dir: /
  github:
    repo: yourusername/tts-tool
    branch: main
  run_command: python main.py --web --port 8080 --host 0.0.0.0
  environment_slug: python
  instance_count: 1
  instance_size_slug: basic-xxs
  envs:
  - key: PORT
    value: 8080
  - key: TTS_DEVICE
    value: cpu
  - key: TTS_CACHE_DIR
    value: /tmp/models_cache
  http_port: 8080
  routes:
  - path: /
databases:
- name: tts-db
  engine: POSTGRESQL
  num_nodes: 1
  size: basic-xs
static_sites: []
jobs: []
```

#### Step 2: Deploy via DigitalOcean Console
1. Go to [DigitalOcean Apps](https://cloud.digitalocean.com/apps)
2. Click "Create App"
3. Connect GitHub repository
4. Choose repository: `yourusername/tts-tool`
5. Configure app:
   - **App name**: `tts-tool`
   - **Region**: Choose closest region
   - **Type**: Web Service
6. Add environment variables:
   ```
   PORT=8080
   TTS_DEVICE=cpu
   TTS_CACHE_DIR=/tmp/models_cache
   ```
7. Click "Next" → "Create Resources"

## 6. AWS/GCP/Azure Deployment

### AWS Deployment with ECS

#### Prerequisites
- AWS CLI configured
- ECR repository created
- ECS cluster created

#### Step 1: Build and Push Docker Image
```bash
# Create ECR repository
aws ecr create-repository --repository-name tts-tool

# Get login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

# Build image
docker build -t tts-tool:latest .

# Tag image
docker tag tts-tool:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/tts-tool:latest

# Push image
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/tts-tool:latest
```

#### Step 2: Create ECS Task Definition
```json
{
  "family": "tts-tool",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "2048",
  "memory": "4096",
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "tts-tool",
      "image": "123456789012.dkr.ecr.us-east-1.amazonaws.com/tts-tool:latest",
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
          "value": "/tmp/models_cache"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/tts-tool",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

#### Step 3: Deploy ECS Service
```bash
# Create ECS service
aws ecs create-service \
  --cluster tts-cluster \
  --service-name tts-tool-service \
  --task-definition tts-tool:1 \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-12345678],securityGroups=[sg-12345678],assignPublicIp=ENABLED}" \
  --load-balancers targetGroupArn=arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/tts-tool-tg/1234567890123456,containerName=tts-tool,containerPort=7860
```

### GCP Deployment with Cloud Run

#### Step 1: Build and Push Image
```bash
# Enable APIs
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com

# Build and push image
gcloud builds submit --tag gcr.io/PROJECT-ID/tts-tool

# Deploy to Cloud Run
gcloud run deploy tts-tool \
  --image gcr.io/PROJECT-ID/tts-tool \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --memory 2Gi \
  --cpu 2 \
  --max-instances 3 \
  --set-env-vars TTS_DEVICE=cpu,TTS_CACHE_DIR=/tmp/models_cache
```

### Azure Deployment with Container Instances

#### Step 1: Create Resource Group
```bash
# Create resource group
az group create --name tts-tool-rg --location eastus

# Create container registry
az acr create --resource-group tts-tool-rg --name ttsregistry --sku Basic

# Build and push image
az acr build --registry ttsregistry --image tts-tool:latest .
```

#### Step 2: Deploy Container
```bash
# Deploy to Container Instances
az container create \
  --resource-group tts-tool-rg \
  --name tts-tool \
  --image ttsregistry.azurecr.io/tts-tool:latest \
  --cpu 2 \
  --memory 4 \
  --ports 7860 \
  --environment-variables \
    TTS_DEVICE=cpu \
    TTS_CACHE_DIR=/tmp/models_cache \
  --dns-name-label tts-tool \
  --location eastus
```

## 🛠️ Platform-Specific Optimizations

### Memory Optimization
```python
# Add to your application for all platforms
import gc
import psutil
import os

def optimize_memory():
    """Optimize memory usage"""
    # Force garbage collection
    gc.collect()
    
    # Clear any model caches if needed
    if 'transformers' in sys.modules:
        from transformers import models
        for model_name, model in list(models.__dict__.items()):
            if hasattr(model, 'clear_memory'):
                model.clear_memory()

def check_memory_usage():
    """Monitor memory usage"""
    process = psutil.Process(os.getpid())
    memory_mb = process.memory_info().rss / 1024 / 1024
    return memory_mb

# Use in application loop
memory_mb = check_memory_usage()
if memory_mb > 3000:  # 3GB threshold
    optimize_memory()
```

### Cold Start Optimization
```python
# Lazy loading for all platforms
class LazyModelLoader:
    def __init__(self):
        self._models = {}
    
    def get_model(self, model_name):
        if model_name not in self._models:
            print(f"📥 Loading {model_name}...")
            self._models[model_name] = self._load_model(model_name)
        return self._models[model_name]
    
    def _load_model(self, model_name):
        # Your model loading logic
        pass
```

## 📊 Platform Comparison & Recommendations

### Development/Testing
1. **Hugging Face Spaces** - Best for demos and sharing
2. **Streamlit Cloud** - Best for Streamlit apps
3. **Render.com** - Good for full-stack development

### Production/Scaling
1. **DigitalOcean App Platform** - Best balance of features and cost
2. **AWS ECS/EKS** - Best for enterprise with existing AWS setup
3. **GCP Cloud Run** - Best for Google ecosystem
4. **Azure Container Instances** - Best for Microsoft ecosystem

### Cost Analysis (Estimated Monthly)

| Platform | Free Tier | Paid Options |
|----------|-----------|--------------|
| **Hugging Face Spaces** | CPU basic | Up to GPU |
| **Streamlit Cloud** | Community cloud | Upgrade available |
| **Render.com** | $0/month | $7/month+ |
| **Railway** | $5/month credit | Pay-per-use |
| **DigitalOcean** | N/A | $5/month+ |
| **AWS ECS** | $0 (if using spot) | $20/month+ |
| **GCP Cloud Run** | 2M requests/month | $0.24/hour |
| **Azure** | $0 (free tier) | $20/month+ |

## 🚀 Deployment Checklist

### Pre-Deployment
- [ ] Code tested locally
- [ ] Dependencies documented
- [ ] Environment variables configured
- [ ] Health check endpoint added
- [ ] Error handling implemented
- [ ] Memory optimization applied
- [ ] Logging configured

### During Deployment
- [ ] Monitor build logs
- [ ] Verify environment variables
- [ ] Check resource limits
- [ ] Test health endpoint
- [ ] Verify application startup
- [ ] Test basic functionality

### Post-Deployment
- [ ] Monitor application logs
- [ ] Test all features
- [ ] Check performance metrics
- [ ] Set up monitoring/alerts
- [ ] Configure backup (if needed)
- [ ] Test scaling (if applicable)
- [ ] Document deployment

## 🔍 Troubleshooting Common Issues

### Build Failures
```bash
# Check Python version compatibility
python --version

# Verify requirements.txt syntax
pip-compile --dry-run requirements.txt

# Check for system dependencies
apt list --installed | grep -E "ffmpeg|soundfile"
```

### Memory Issues
```bash
# Monitor memory usage
docker stats

# Check container logs
docker logs <container-id>

# Optimize model loading
# Use CPU-only mode in cloud environments
export TTS_DEVICE=cpu
```

### Port Issues
```python
# Use environment variables for port
import os
PORT = int(os.environ.get('PORT', 8000))

# Bind to 0.0.0.0 for cloud platforms
app.run(host='0.0.0.0', port=PORT)
```

### Model Download Issues
```python
# Cache models properly
CACHE_DIR = os.environ.get('TTS_CACHE_DIR', './models_cache')
os.makedirs(CACHE_DIR, exist_ok=True)

# Use offline mode if models are pre-cached
transformers.offline = os.environ.get('TRANSFORMERS_OFFLINE', False)
```

## 📞 Getting Help

### Platform Documentation
- [Hugging Face Spaces Docs](https://huggingface.co/docs/spaces)
- [Streamlit Cloud Docs](https://docs.streamlit.io/streamlit-cloud)
- [Render Docs](https://render.com/docs)
- [Railway Docs](https://docs.railway.app)
- [DigitalOcean Apps Docs](https://docs.digitalocean.com/products/app-platform/)

### Community Support
- [Stack Overflow](https://stackoverflow.com/questions/tagged/huggingface)
- [Reddit r/MachineLearning](https://reddit.com/r/MachineLearning)
- [Discord communities](https://discord.gg/huggingface)

---

**🎉 Congratulations!** Your TTS Tool is now deployed to the cloud. Choose the platform that best fits your needs and budget, and start sharing your amazing TTS application with the world!

For monitoring and production best practices, see [COMPLETE_PROJECT_SUMMARY.md](COMPLETE_PROJECT_SUMMARY.md).