# 📋 TTS Tool Deployment Checklist

**Complete pre-deployment, configuration, testing, and post-deployment validation checklist**

---

## ✅ Pre-Deployment Checklist

### System Requirements Verification

#### Minimum System Requirements
- [ ] **Operating System:** Linux (Ubuntu 20.04+), Windows 10+, or macOS 10.14+
- [ ] **Python Version:** 3.8+ installed (3.10 recommended)
- [ ] **RAM:** 4GB minimum (8GB recommended)
- [ ] **Storage:** 10GB free space (50GB for model cache)
- [ ] **CPU:** 2+ cores (4+ recommended)
- [ ] **Network:** Stable internet connection for model downloads

#### Optional GPU Requirements (for faster inference)
- [ ] **GPU:** NVIDIA GPU with 6GB+ VRAM
- [ ] **CUDA:** 11.7+ or 12.0+ installed
- [ ] **NVIDIA Driver:** 515+ installed
- [ ] **GPU Support Verified:** `nvidia-smi` command works

### Software Dependencies

#### Core Dependencies
- [ ] **Git** installed and configured
- [ ] **Docker** 20.10+ installed (for containerized deployment)
- [ ] **Docker Compose** 2.0+ installed (for production deployment)
- [ ] **pip** package manager up to date
- [ ] **Virtual environment** tool available (venv, conda, or pyenv)

#### Audio System Dependencies
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y ffmpeg libasound2-dev portaudio19-dev libsndfile1

# CentOS/RHEL
sudo yum install -y alsa-utils-devel portaudio-devel ffmpeg libsndfile-devel

# macOS
brew install portaudio ffmpeg libsndfile

# Windows (using Chocolatey)
choco install ffmpeg
```

- [ ] **FFmpeg** installed and in PATH
- [ ] **PortAudio** installed (for audio playback)
- [ ] **ALSA/PulseAudio** working (Linux)
- [ ] **Audio system functional** (test with `speaker-test` or `afplay`)

### Code Repository Setup

#### Repository Initialization
- [ ] **Repository Cloned:**
  ```bash
  git clone https://github.com/yourusername/tts-tool.git
  cd tts-tool
  ```

- [ ] **Git Configuration:**
  ```bash
  git config --global user.name "Your Name"
  git config --global user.email "your.email@example.com"
  ```

- [ ] **Branch Verification:**
  ```bash
  git branch -a
  git checkout main
  ```

- [ ] **Repository Structure Verified:**
  ```bash
  bash verify_structure.sh
  ```

### Python Environment Setup

#### Virtual Environment Creation
- [ ] **Python Version Check:**
  ```bash
  python --version  # Should be 3.8+
  python3 --version
  ```

- [ ] **Virtual Environment Created:**
  ```bash
  # Option 1: venv
  python -m venv venv
  
  # Option 2: conda
  conda create -n tts-tool python=3.10
  
  # Option 3: pyenv (Linux/macOS)
  pyenv install 3.10.12
  pyenv local 3.10.12
  python -m venv .venv
  ```

- [ ] **Virtual Environment Activated:**
  ```bash
  # venv
  source venv/bin/activate  # Linux/macOS
  venv\Scripts\activate     # Windows
  
  # conda
  conda activate tts-tool
  ```

#### Dependency Installation
- [ ] **PIP Updated:**
  ```bash
  pip install --upgrade pip
  ```

- [ ] **Core Dependencies Installed:**
  ```bash
  pip install -r requirements.txt
  ```

- [ ] **Development Dependencies Installed (Optional):**
  ```bash
  pip install -r requirements-dev.txt
  ```

- [ ] **Package Installation Verified:**
  ```bash
  pip list | grep -E "(torch|transformers|gradio|librosa)"
  ```

---

## ⚙️ Configuration Validation

### Environment Variables Configuration

#### Core Configuration (.env file)
Create `.env` file with required variables:
```bash
# Core Application Settings
TTS_DEVICE=cpu                          # cpu, cuda, or mps
TTS_CACHE_DIR=./models_cache            # Directory for model cache
TTS_MAX_TEXT_LENGTH=5000                # Maximum text length
TTS_DEFAULT_MODEL=speecht5              # Default TTS model

# Web Interface Settings
TTS_WEB_PORT=7860                       # Web interface port
TTS_WEB_HOST=0.0.0.0                    # Web interface host
TTS_WEB_SHARE=false                     # Create shareable link

# Performance Settings
TTS_WORKERS=4                           # Number of worker processes
TTS_BATCH_SIZE=8                        # Batch processing size
TTS_MEMORY_LIMIT=8GB                    # Memory limit

# Logging Configuration
TTS_LOG_LEVEL=INFO                      # Logging level
TTS_LOG_FILE=./logs/tts.log             # Log file path

# Security Settings (Production)
SECRET_KEY=your-secret-key-here         # Application secret key
ALLOWED_HOSTS=localhost,127.0.0.1       # Allowed hostnames
CORS_ALLOWED_ORIGINS=*                  # CORS origin whitelist
```

- [ ] **Environment file created:** `.env`
- [ ] **Secret key generated:** `python -c "import secrets; print(secrets.token_hex(32))"`
- [ ] **Configuration variables validated:**
  ```bash
  python deployment_validator.py --env-check
  ```

### Model Configuration

#### Model Download and Caching
- [ ] **Cache Directory Created:**
  ```bash
  mkdir -p models_cache outputs logs
  ```

- [ ] **Model Download Tested:**
  ```bash
  python -c "
  from transformers import SpeechT5Processor
  processor = SpeechT5Processor.from_pretrained('microsoft/speecht5_tts')
  print('✅ SpeechT5 model downloaded successfully')
  "
  ```

- [ ] **Multiple Models Verified:**
  ```bash
  python main.py --list-models
  ```

### Platform-Specific Configuration

#### Docker Configuration
- [ ] **Docker Daemon Running:**
  ```bash
  docker --version
  docker ps
  ```

- [ ] **Docker Build Test:**
  ```bash
  docker build -t tts-tool:test .
  ```

- [ ] **Docker Compose Test:**
  ```bash
  docker-compose config --quiet
  ```

#### Cloud Platform Configuration

##### Hugging Face Spaces
- [ ] **Hugging Face Account:** Account created and verified
- [ ] **Hugging Face CLI:** Installed (`pip install huggingface_hub`)
- [ ] **Authentication:** Logged in (`huggingface-cli login`)
- [ ] **Space Creation Ready:** Repository structure prepared

##### Streamlit Cloud
- [ ] **Streamlit Installation:** `pip install streamlit`
- [ ] **GitHub Account:** Connected to Streamlit Cloud
- [ ] **Repository Structure:** Streamlit app created

##### Render.com
- [ ] **Render Account:** Account created
- [ ] **GitHub Integration:** Repository connected
- [ ] **Configuration Files:** `render.yaml` and `build.sh` ready

##### AWS/GCP/Azure
- [ ] **Cloud CLI:** AWS CLI / gcloud CLI / Azure CLI installed
- [ ] **Authentication:** Credentials configured
- [ ] **Permissions:** Required permissions verified

---

## 🧪 Testing Procedures

### Basic Functionality Tests

#### Import Tests
```bash
# Test core imports
python -c "
import torch
import transformers
import gradio
import librosa
import soundfile
print('✅ All core dependencies imported successfully')
"
```

- [ ] **Core imports working**
- [ ] **TTS module imports working:**
  ```bash
  python -c "
  from src.tts_tool import TTSProcessor, AdvancedTTSProcessor
  print('✅ TTS modules imported successfully')
  "
  ```

#### Model Loading Tests
```bash
# Test model loading
python -c "
from src.tts_tool import TTSProcessor
processor = TTSProcessor('speecht5')
print('✅ SpeechT5 model loaded successfully')
"
```

- [ ] **SpeechT5 model loads**
- [ ] **MMS-TTS model loads:**
  ```bash
  python -c "
  from src.tts_tool import TTSProcessor
  processor = TTSProcessor('mms_tts')
  print('✅ MMS-TTS model loaded successfully')
  "
  ```

#### Single Text Conversion Test
```bash
# Test single text conversion
python main.py --text "Hello, this is a test." --output test_output.wav
```

- [ ] **Text conversion completes without errors**
- [ ] **Output file created:** `test_output.wav`
- [ ] **Audio file is valid:** Check file size > 0

#### Web Interface Test
```bash
# Test web interface
python main.py --web --port 7860 --verbose
```

- [ ] **Web interface starts successfully**
- [ ] **Port 7860 accessible:** `curl http://localhost:7860`
- [ ] **Interface loads in browser:** Open http://localhost:7860

### Performance Tests

#### Memory Usage Test
```bash
# Monitor memory during operation
python main.py --text "This is a longer test text to check memory usage with more processing." --output memory_test.wav

# Check memory usage
ps aux | grep python | grep -v grep
```

- [ ] **Memory usage within limits**
- [ ] **No memory leaks detected**

#### Batch Processing Test
```bash
# Create test file
echo -e "Test 1\nTest 2\nTest 3" > batch_test.txt

# Test batch processing
python main.py --batch batch_test.txt --output-dir batch_output --workers 2
```

- [ ] **Batch processing completes**
- [ ] **All output files created**
- [ ] **No processing errors**

### Platform-Specific Tests

#### Docker Container Test
```bash
# Build and run container
docker build -t tts-tool:test .
docker run -p 7860:7860 tts-tool:test

# Test from host
curl http://localhost:7860
```

- [ ] **Container builds successfully**
- [ ] **Container runs without errors**
- [ ] **Web interface accessible in container**

#### Docker Compose Test
```bash
# Test docker-compose configuration
docker-compose -f deployment_configs/docker/docker-compose.prod.yml config

# Start services
docker-compose -f deployment_configs/docker/docker-compose.prod.yml up -d

# Check services
docker-compose -f deployment_configs/docker/docker-compose.prod.yml ps
```

- [ ] **All services start successfully**
- [ ] **Services are healthy**
- [ ] **Monitoring stack accessible**

### Cloud Platform Tests

#### Local Simulation Test
```bash
# Test Hugging Face Spaces configuration locally
cd deployment_configs/huggingface/
python app.py --port 7860
```

- [ ] **Spaces app runs locally**
- [ ] **All features work correctly**

#### Streamlit Test
```bash
# Test Streamlit configuration locally
cd deployment_configs/streamlit/
streamlit run streamlit_app.py --server.port 7860
```

- [ ] **Streamlit app runs locally**
- [ ] **All tabs and features work**

---

## 🔍 Post-Deployment Verification

### Deployment Success Validation

#### Application Health Check
```bash
# Check if application is responding
curl -f http://localhost:7860

# Check health endpoint (if available)
curl -f http://localhost:7860/health
```

- [ ] **HTTP response is 200**
- [ ] **Application responds within 5 seconds**
- [ ] **No error messages in logs**

#### Functionality Verification
- [ ] **Text-to-speech conversion works**
- [ ] **Audio playback functions**
- [ ] **Batch processing works**
- [ ] **Model switching works**
- [ ] **File downloads work**

#### Performance Verification
```bash
# Check response times
time curl -f http://localhost:7860

# Check resource usage
docker stats  # If using Docker

# Check disk usage
df -h
du -sh models_cache/
```

- [ ] **Response time < 2 seconds**
- [ ] **CPU usage < 80%**
- [ ] **Memory usage < 80%**
- [ ] **Disk usage < 90%**

### Monitoring Setup Verification

#### Logging Verification
```bash
# Check log files exist and are being written to
ls -la logs/
tail -f logs/tts.log
```

- [ ] **Log files created**
- [ ] **Logs are being written**
- [ ] **Log levels are correct**

#### Monitoring Services Verification
```bash
# Check Grafana
curl -f http://localhost:3000

# Check Prometheus
curl -f http://localhost:9090

# Check application metrics
curl http://localhost:9090/metrics | grep tts_
```

- [ ] **Grafana accessible**
- [ ] **Prometheus accessible**
- [ ] **Application metrics available**

### Security Verification

#### Security Headers Check
```bash
# Check security headers
curl -I http://localhost:7860

# Should include:
# - X-Content-Type-Options
# - X-Frame-Options
# - X-XSS-Protection
```

- [ ] **Security headers present**
- [ ] **HTTPS enabled (production)**
- [ ] **No sensitive data in logs**

#### Access Control Verification
- [ ] **Unauthorized access blocked**
- [ ] **Rate limiting active**
- [ ] **Input validation working**

### Backup Verification

#### Backup Script Test
```bash
# Test database backup
./production/backup/database-backup.sh test-backup

# Test model cache backup
./production/backup/model-backup.sh test-backup
```

- [ ] **Backup scripts execute successfully**
- [ ] **Backup files created**
- [ ] **Backup integrity verified**

#### Recovery Test (Safe Environment)
```bash
# Test backup restoration (in test environment)
./production/backup/database-backup.sh verify --file /backups/latest.sql.gz
```

- [ ] **Backup verification passes**
- [ ] **Recovery procedures documented**

---

## 🚨 Common Issues and Solutions

### Pre-Deployment Issues

#### Python/Dependency Issues
**Problem:** Import errors or missing modules
```bash
# Solution
pip install --upgrade pip
pip install -r requirements.txt --force-reinstall
```

#### Audio System Issues
**Problem:** No audio output or playback errors
```bash
# Solution
sudo apt install -y alsa-utils pulseaudio
export PULSE_SERVER=unix:/tmp/pulse-socket  # If needed
```

#### GPU Issues
**Problem:** CUDA not available or GPU not detected
```bash
# Solution
export CUDA_VISIBLE_DEVICES=0
python -c "import torch; print(torch.cuda.is_available())"
```

### Deployment Issues

#### Port Already in Use
```bash
# Find process using port
lsof -i :7860

# Kill process
kill -9 <PID>

# Or use different port
python main.py --web --port 8080
```

#### Model Download Failures
```bash
# Clear cache and retry
rm -rf models_cache/
export HF_ENDPOINT=https://hf-mirror.com  # If in China
```

#### Docker Issues
```bash
# Check Docker daemon
sudo systemctl status docker

# Rebuild without cache
docker build --no-cache -t tts-tool .

# Check container logs
docker logs <container_name>
```

### Performance Issues

#### High Memory Usage
```bash
# Reduce batch size
python main.py --batch texts.txt --workers 2

# Use CPU instead of GPU
export TTS_DEVICE=cpu
```

#### Slow Generation
```bash
# Use smaller model
python main.py --model mms_tts

# Enable caching
export TTS_CACHE_DIR=/fast/ssd/cache
```

---

## ✅ Final Validation Checklist

### Pre-Production Checklist
- [ ] All tests pass locally
- [ ] Performance is acceptable
- [ ] Security configurations verified
- [ ] Monitoring setup complete
- [ ] Backup procedures tested
- [ ] Documentation updated
- [ ] Team notification sent

### Production Deployment Checklist
- [ ] Environment variables configured
- [ ] SSL certificates installed (if HTTPS)
- [ ] Domain name configured (if applicable)
- [ ] DNS settings updated (if applicable)
- [ ] Load balancer configured (if applicable)
- [ ] Monitoring alerts configured
- [ ] Backup schedule configured

### Post-Production Checklist
- [ ] Application health verified
- [ ] User acceptance testing complete
- [ ] Performance monitoring active
- [ ] Error tracking active
- [ ] Incident response plan reviewed
- [ ] Team trained on procedures
- [ ] Documentation finalized

---

## 📞 Emergency Procedures

### Emergency Stop
```bash
# Stop all services
./production/scripts/stop-production.sh --emergency

# Kill all processes
pkill -f "python main.py"
pkill -f "gradio"
```

### Emergency Backup
```bash
# Create immediate backup
./production/backup/database-backup.sh emergency-backup
```

### Emergency Contact
- **On-Call Engineer:** [Contact information]
- **System Administrator:** [Contact information]
- **DevOps Team:** [Contact information]

---

**Checklist Version:** 1.0.0  
**Last Updated:** November 2, 2025  
**Next Review:** February 2, 2026

*Complete this checklist before proceeding with any production deployment*