# ⚡ TTS Tool Quick Start Guide

**Get the TTS Tool deployed and running in 5-15 minutes**

---

## 🚀 Fastest Deployment (5 minutes)

### Option 1: Hugging Face Spaces (Recommended for sharing)

```bash
# 1. Copy Hugging Face configuration
cp -r deployment_configs/huggingface/* ./

# 2. Add all files to git
git add .

# 3. Commit and push
git commit -m "Deploy TTS Tool to Hugging Face Spaces"
git push origin main

# 4. Your app will be live at:
# https://yourusername-tts-tool.hf.space
```

**✅ Done! Your TTS Tool is now live on Hugging Face Spaces**

---

## ⚡ Quick Local Setup (10 minutes)

### Step 1: Clone and Setup (2 minutes)
```bash
# Clone repository
git clone https://github.com/yourusername/tts-tool.git
cd tts-tool

# Create virtual environment
python -m venv venv

# Activate environment
source venv/bin/activate  # Linux/macOS
# OR
venv\Scripts\activate     # Windows

# Install dependencies
pip install -r requirements.txt
```

### Step 2: Test Installation (1 minute)
```bash
# Test basic functionality
python main.py --text "Hello, this is a test." --output test.wav

# If test.wav is created, you're ready!
```

### Step 3: Launch Web Interface (1 minute)
```bash
# Start web interface
python main.py --web

# Open browser to: http://localhost:7860
```

**✅ Done! Access your TTS Tool at http://localhost:7860**

---

## 🐳 Docker Quick Start (15 minutes)

### Step 1: Build and Run (5 minutes)
```bash
# Build Docker image
docker build -t tts-tool:latest .

# Run container
docker run -d --name tts-app -p 7860:7860 tts-tool:latest

# Check status
docker ps | grep tts-app
```

### Step 2: Access Application (1 minute)
```bash
# Wait for container to start (30-60 seconds)
docker logs -f tts-app

# Access at: http://localhost:7860
```

**✅ Done! Your TTS Tool is running in Docker**

---

## 🌟 Platform-Specific Quick Deploys

### Render.com (10 minutes)

1. **Connect Repository:**
   - Visit [render.com](https://render.com)
   - Sign in with GitHub
   - Click "New" → "Web Service"

2. **Configure Service:**
   ```yaml
   Name: tts-tool
   Runtime: Python 3
   Build Command: pip install -r requirements.txt
   Start Command: python main.py --web --port $PORT --host 0.0.0.0
   Plan: Free
   ```

3. **Deploy:**
   - Click "Create Web Service"
   - Wait for deployment (5-10 minutes)

**✅ Done! Access at: https://your-service-name.onrender.com**

### Streamlit Cloud (10 minutes)

1. **Create Streamlit App:**
   ```bash
   cp deployment_configs/streamlit/streamlit_app.py streamlit_app.py
   ```

2. **Deploy:**
   - Visit [share.streamlit.io](https://share.streamlit.io)
   - Sign in with GitHub
   - Click "New app"
   - Select your repository and `streamlit_app.py`

**✅ Done! Access at: https://yourusername-streamlit-app.streamlit.app**

### Heroku (10 minutes)

```bash
# Install Heroku CLI, then:
heroku create your-tts-tool-app
cp deployment_configs/streamlit/Procfile .
echo "python-3.10.12" > runtime.txt
git add .
git commit -m "Deploy to Heroku"
git push heroku main

# Your app will be at: https://your-tts-tool-app.herokuapp.com
```

---

## 🎯 Essential Commands

### Basic Usage
```bash
# Convert text to speech
python main.py --text "Your text here" --output output.wav

# Use different model
python main.py --text "Hello" --model mms_tts --output hello.wav

# Batch conversion
python main.py --batch texts.txt --output-dir batch_output

# Convert audio format
python main.py --convert-audio input.wav --format mp3
```

### Web Interface Options
```bash
# Standard web interface
python main.py --web

# Custom port
python main.py --web --port 8080

# Shareable link
python main.py --web --share

# Verbose mode
python main.py --web --verbose
```

### Model Information
```bash
# List available models
python main.py --list-models

# Get model details
python main.py --model-info speecht5
```

---

## ⚙️ Key Configurations

### Environment Variables (.env)
```bash
# Core settings
TTS_DEVICE=cpu                    # cpu, cuda, or mps
TTS_CACHE_DIR=./models_cache      # Model cache location
TTS_WEB_PORT=7860                 # Web interface port
TTS_DEFAULT_MODEL=speecht5        # Default model

# Performance
TTS_WORKERS=4                     # Parallel workers
TTS_BATCH_SIZE=8                  # Batch processing size
TTS_LOG_LEVEL=INFO                # Logging level
```

### Quick Configuration Changes
```bash
# Use GPU (if available)
export TTS_DEVICE=cuda

# Change web port
python main.py --web --port 8080

# Use different model
python main.py --text "Hello" --model bark --output creative.wav

# Enable verbose logging
python main.py --web --verbose
```

---

## 🔧 Common Solutions

### Issue: "Port already in use"
```bash
# Find and kill process
lsof -ti:7860 | xargs kill -9

# Or use different port
python main.py --web --port 8080
```

### Issue: "Model download failed"
```bash
# Clear cache and retry
rm -rf models_cache/
python main.py --text "Test" --output test.wav
```

### Issue: "Import error"
```bash
# Reinstall dependencies
pip install -r requirements.txt --force-reinstall
```

### Issue: "No audio output"
```bash
# Install audio dependencies
sudo apt install -y alsa-utils pulseaudio  # Ubuntu
brew install portaudio                     # macOS
choco install ffmpeg                       # Windows
```

---

## 🎛️ Advanced Quick Setup

### Production Docker Stack (15 minutes)
```bash
# Start full production stack
cd deployment_configs/docker/
docker-compose -f docker-compose.prod.yml up -d

# Access services:
# - Main app: http://localhost:8080
# - Grafana: http://localhost:3000 (admin/admin)
# - Prometheus: http://localhost:9090
```

### Development Environment (5 minutes)
```bash
# Install development dependencies
pip install -r requirements-dev.txt

# Run tests
python -m pytest tests/

# Start development server
python main.py --web --verbose
```

### GPU Setup (5 minutes)
```bash
# Check GPU availability
nvidia-smi

# Install PyTorch with CUDA
pip install torch torchaudio --index-url https://download.pytorch.org/whl/cu118

# Use GPU
export TTS_DEVICE=cuda
python main.py --web --verbose
```

---

## 📊 Performance Tips

### Faster Inference
```bash
# Use MMS-TTS model (faster)
python main.py --text "Hello" --model mms_tts

# Use CPU optimizations
export OMP_NUM_THREADS=4
export TTS_WORKERS=2

# Enable caching
export TTS_CACHE_DIR=/fast/ssd/cache
```

### Memory Optimization
```bash
# Reduce batch size
python main.py --batch texts.txt --workers 2

# Use smaller models
python main.py --model mms_tts

# Clear cache periodically
rm -rf models_cache/*
```

### Web Interface Optimization
```bash
# Faster loading
python main.py --web --port 7860

# Shareable link for remote access
python main.py --web --share

# Disable auto-open browser
python main.py --web --no-browser
```

---

## 📱 Mobile-Friendly Usage

### Access from Mobile Device
```bash
# Start on all interfaces
python main.py --web --host 0.0.0.0 --port 7860

# Access from mobile at: http://YOUR_IP:7860
# Find your IP: ip addr show (Linux) or ifconfig (macOS)
```

### Share with Others
```bash
# Create shareable link
python main.py --web --share

# Or use ngrok (if installed)
ngrok http 7860
# Share the ngrok URL
```

---

## 🎯 Use Cases & Examples

### Educational Content
```bash
# Convert lesson notes to audio
python main.py --text "Today we will learn about photosynthesis..." --output lesson.wav

# Multiple languages
python main.py --text "Bonjour, comment allez-vous?" --model mms_tts --language fr --output french.wav
```

### Accessibility
```bash
# Audio books
python main.py --batch chapter.txt --output-dir audiobook --model bark

# Voice for visually impaired
python main.py --text "Email from John: Meeting at 3 PM" --output notification.wav
```

### Creative Content
```bash
# Storytelling with emotions
python main.py --text "Once upon a time..." --model bark --emotion whisper --output story.wav

# Character voices
python main.py --text "I am the wise old wizard!" --model bark --emotion excited --output wizard.wav
```

### Business Applications
```bash
# Customer service scripts
python main.py --batch customer_service.txt --output-dir cs_audio --model speecht5

# Multi-language announcements
python main.py --text "Welcome to our store" --model mms_tts --language es --output spanish.wav
```

---

## 🔗 Useful Links

### Documentation
- **Main Guide:** `DEPLOYMENT.md`
- **Full Checklist:** `DEPLOYMENT_CHECKLIST.md`
- **Production Guide:** `production/README.md`

### Monitoring & Management
- **Health Check:** `curl http://localhost:7860`
- **Logs:** `tail -f logs/tts.log`
- **System Status:** `./production/scripts/health-check.sh`

### Community & Support
- **GitHub Issues:** Report bugs and feature requests
- **GitHub Discussions:** Community Q&A
- **Documentation Wiki:** Extended documentation

---

## ⚡ One-Line Commands

### Instant Test
```bash
# One-line test
git clone https://github.com/yourusername/tts-tool.git && cd tts-tool && python -m venv venv && source venv/bin/activate && pip install -r requirements.txt && python main.py --text "Hello World" --output hello.wav && echo "✅ TTS Tool working!" || echo "❌ Setup failed"
```

### Instant Web Interface
```bash
# One-line web interface
python -m pip install transformers torch gradio && python main.py --web --share
```

### Docker Quick Start
```bash
# One-line Docker
docker build -t tts-tool . && docker run -d -p 7860:7860 --name tts-app tts-tool && echo "🌐 Access at: http://localhost:7860"
```

---

## 🎉 You're Ready!

**Congratulations! Your TTS Tool is now deployed and ready to use.**

### Next Steps:
1. **Explore the web interface** at your deployment URL
2. **Try different models** - SpeechT5, MMS-TTS, and Bark
3. **Experiment with emotions** - happy, sad, excited, whisper
4. **Test batch processing** for multiple texts
5. **Customize the configuration** for your needs

### Need Help?
- 📚 **Full Documentation:** See `DEPLOYMENT.md`
- 🛠️ **Troubleshooting:** See `DEPLOYMENT_CHECKLIST.md`
- 🏭 **Production Setup:** See `production/README.md`
- 🐛 **Report Issues:** GitHub Issues
- 💬 **Community:** GitHub Discussions

---

**Quick Start Guide Version:** 1.0.0  
**Deployment Time:** 5-15 minutes  
**Complexity Level:** Beginner to Advanced  

*Get started in minutes, scale to production*