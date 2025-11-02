# 🎤 TTS Tool - Text-to-Speech Converter

[![CI/CD Pipeline](https://github.com/yourusername/tts-tool/workflows/CI/CD%20Pipeline/badge.svg)](https://github.com/yourusername/tts-tool/actions)
[![PyPI Version](https://img.shields.io/pypi/v/tts-tool)](https://pypi.org/project/tts-tool/)
[![Python Version](https://img.shields.io/pypi/pyversions/tts-tool)](https://pypi.org/project/tts-tool/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Downloads](https://pepy.tech/badge/tts-tool)](https://pepy.tech/project/tts-tool)
[![codecov](https://codecov.io/gh/yourusername/tts-tool/branch/main/graph/badge.svg)](https://codecov.io/gh/yourusername/tts-tool)
[![Documentation](https://img.shields.io/badge/docs-latest-blue.svg)](https://tts-tool.readthedocs.io/)

[![TTS Models](https://img.shields.io/badge/TTS-Models-orange)](https://github.com/yourusername/tts-tool)
[![Gradio Interface](https://img.shields.io/badge/Gradio-Purple)](https://gradio.app/)
[![GPU Support](https://img.shields.io/badge/GPU-Support-green)](https://github.com/yourusername/tts-tool)
[![Docker Ready](https://img.shields.io/badge/Docker-Ready-blue)](https://www.docker.com/)

A comprehensive, production-ready Text-to-Speech (TTS) converter powered by state-of-the-art AI models. Features multiple TTS engines, web interface, batch processing, dataset integration, and seamless deployment options.

## ✨ Key Features

### 🤖 **Multiple TTS Models**
- **Microsoft SpeechT5**: High-quality English TTS with speaker control
- **Facebook MMS-TTS**: Multilingual support (20+ languages), optimized for speed
- **Suno Bark**: Creative multilingual TTS with emotions and sound effects

### 🎵 **Audio Processing**
- **Multi-format Support**: WAV, MP3, FLAC, OGG, and more
- **Advanced Processing**: Audio normalization, effects, and enhancement
- **Batch Processing**: Convert multiple texts efficiently with parallel workers
- **Format Conversion**: Seamless conversion between audio formats

### 🎭 **Advanced Features**
- **Emotion Control**: Add emotions (happy, sad, excited, whisper) to speech
- **Speaker Voice Control**: Different speaker embeddings with SpeechT5
- **Language Support**: 20+ languages with automatic detection
- **Creative Audio**: Sound effects and expressive audio generation

### 📊 **Dataset Integration**
- **Hugging Face Datasets**: LJ Speech, Common Voice, VCTK support
- **Dataset Analysis**: Statistical analysis and visualization
- **Training Preparation**: Format data for TTS model training

### 🌐 **Web Interface**
- **Beautiful Gradio Interface**: Intuitive, real-time web interface
- **Real-time Generation**: Instant audio playback and download
- **Multiple Tabs**: Single conversion, batch processing, settings, and more
- **Mobile Responsive**: Works on desktop and mobile devices

## 🚀 Quick Start

### Option 1: Docker (Recommended)
```bash
# Clone and run with Docker
git clone https://github.com/yourusername/tts-tool.git
cd tts-tool

# Build and run
docker build -t tts-tool .
docker run -p 7860:7860 tts-tool

# Access web interface
open http://localhost:7860
```

### Option 2: Python Installation
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

### Option 3: Pip Package
```bash
# Install from PyPI
pip install tts-tool

# Run directly
tts-tool --web
```

## 📱 Screenshots

### Web Interface
![TTS Tool Web Interface](https://via.placeholder.com/800x600?text=TTS+Tool+Web+Interface)

### Batch Processing
![Batch Processing](https://via.placeholder.com/800x400?text=Batch+Processing+Demo)

### Command Line Interface
![CLI Interface](https://via.placeholder.com/800x300?text=Command+Line+Interface)

## 💻 Usage Examples

### Python API

#### Basic TTS
```python
from tts_tool import TTSProcessor

# Initialize processor
processor = TTSProcessor("speecht5")

# Generate speech
text = "Hello, this is a test of the text-to-speech system."
audio_file = processor.generate_speech(text, "output.wav")

print(f"Audio generated: {audio_file}")
```

#### Advanced TTS with Emotions
```python
from tts_tool import AdvancedTTSProcessor

# Initialize advanced processor
processor = AdvancedTTSProcessor("bark")

# Generate with emotions
text = "This is an exciting announcement!"

emotions = ["happy", "excited", "neutral", "whisper"]
for emotion in emotions:
    output_file = processor.generate_with_emotion(text, emotion)
    print(f"Generated {emotion} version: {output_file}")
```

#### Batch Processing
```python
from tts_tool import BatchTTSProcessor

# Initialize batch processor
batch_processor = BatchTTSProcessor("speecht5", max_workers=4)

# Process multiple texts
texts = [
    "First sentence to convert.",
    "Second sentence to convert.",
    "Third sentence to convert."
]

results = batch_processor.process_batch(
    texts, 
    output_dir="batch_output",
    progress_callback=lambda completed, total: print(f"Progress: {completed}/{total}")
)

print(f"✅ Processed {len(results)} texts")
```

### Command Line Interface

#### Single Text Conversion
```bash
# Convert text to speech
python main.py --text "Hello world" --output hello.wav

# With emotion
python main.py --text "This is exciting!" --emotion happy --output excited.wav

# With specific model
python main.py --text "Bonjour le monde" --model mms_tts --language fr --output french.mp3
```

#### Batch Conversion
```bash
# Batch processing from file
python main.py --batch texts.txt --output-dir batch_output

# With custom settings
python main.py --batch texts.txt --output-dir batch_output --workers 8 --emotion neutral
```

#### Audio Format Conversion
```bash
# Convert audio format
python main.py --convert-audio input.wav --format mp3 --bitrate 192k

# Batch conversion
python main.py --convert-audio *.wav --format flac
```

#### Dataset Analysis
```bash
# Analyze LJ Speech dataset
python main.py --analyze-dataset lj_speech --analysis-output lj_analysis.json

# Analyze Common Voice
python main.py --analyze-dataset common_voice --language en --analysis-output cv_analysis.json
```

### Web Interface Usage

1. **🎵 Single Conversion Tab**
   - Enter text in the text area
   - Select TTS model and emotion
   - Click "Generate Speech"
   - Play and download audio file

2. **📦 Batch Processing Tab**
   - Upload text file or paste multiple texts
   - Configure batch settings
   - Start processing
   - Download results as ZIP

3. **🔄 Audio Converter Tab**
   - Upload audio file
   - Select target format and settings
   - Convert and download

4. **📊 Dataset Analysis Tab**
   - Select dataset to analyze
   - View statistics and visualizations
   - Download analysis reports

5. **⚙️ Settings Tab**
   - Configure default models
   - View system information
   - Test audio output

## 📊 Model Comparison

| Feature | SpeechT5 | MMS-TTS | Bark |
|---------|----------|---------|------|
| **Quality** | High | Medium | Very High |
| **Speed** | Medium | Fast | Slow |
| **Languages** | English | 20+ | 13 |
| **Memory Usage** | Medium | Low | High |
| **Special Features** | Speaker Control | Multilingual | Creative Audio |
| **Best For** | Professional TTS | Edge Deployment | Creative Content |
| **GPU Required** | Optional | No | Recommended |
| **Batch Processing** | ✅ | ✅ | ✅ |

## 🛠️ Installation Options

### Development Installation
```bash
# Clone repository
git clone https://github.com/yourusername/tts-tool.git
cd tts-tool

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
pip install -r requirements-dev.txt

# Install in development mode
pip install -e .

# Run tests
pytest tests/
```

### GPU Support
```bash
# Install PyTorch with CUDA support
pip install torch torchaudio --index-url https://download.pytorch.org/whl/cu118

# Run with GPU acceleration
python main.py --web --device cuda
```

### Docker with GPU Support
```bash
# Build GPU-enabled Docker image
docker build -f Dockerfile.gpu -t tts-tool:gpu .

# Run with GPU support
docker run --gpus all -p 7860:7860 tts-tool:gpu
```

## 🏗️ Architecture

```
tts-tool/
├── src/tts_tool/              # Core Python package
│   ├── __init__.py            # Package initialization
│   ├── tts_processor.py       # Core TTS processing
│   ├── advanced_tts.py        # Advanced features
│   ├── batch_processor.py     # Batch processing
│   ├── dataset_integration.py # Dataset handling
│   ├── audio_processing.py    # Audio format conversion
│   └── gradio_interface.py    # Web interface
├── examples/                   # Usage examples
├── tests/                      # Test suite
├── docs/                       # Documentation
├── main.py                     # CLI entry point
├── requirements.txt            # Core dependencies
├── requirements-dev.txt        # Development dependencies
├── Dockerfile                  # Docker configuration
├── docker-compose.yml          # Docker Compose setup
├── DEPLOYMENT.md              # Deployment guide
└── DEPLOY_GUIDE.md            # Detailed deployment instructions
```

## 🔧 Configuration

### Environment Variables
```bash
# Core settings
export TTS_DEVICE="cpu"                    # cpu, cuda, mps
export TTS_CACHE_DIR="./models_cache"      # Model cache directory
export TTS_MAX_TEXT_LENGTH="5000"         # Maximum text length

# Web interface
export TTS_WEB_PORT="7860"                # Web interface port
export TTS_WEB_HOST="0.0.0.0"             # Web interface host
export TTS_WEB_SHARE="false"              # Create shareable link

# Performance
export TTS_WORKERS="4"                    # Parallel workers
export TTS_BATCH_SIZE="8"                 # Batch size
export TTS_MEMORY_LIMIT="8GB"             # Memory limit

# Models
export TTS_DEFAULT_MODEL="speecht5"       # Default TTS model
export TTS_MODEL_CACHE_SIZE="3"           # Models to cache

# Logging
export TTS_LOG_LEVEL="INFO"               # Logging level
export TTS_LOG_FILE="./logs/tts.log"      # Log file path
```

### Configuration File
Create `config/settings.yaml`:
```yaml
models:
  default: "speecht5"
  cache_dir: "./models_cache"
  device: "cpu"

web:
  host: "0.0.0.0"
  port: 7860
  share: false

performance:
  workers: 4
  batch_size: 8
  memory_limit: "8GB"

logging:
  level: "INFO"
  file: "./logs/tts.log"
```

## 🧪 Testing

### Run Test Suite
```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=src/tts_tool

# Run specific test
pytest tests/test_tts_processor.py

# Run integration tests
pytest tests/integration/
```

### Test Examples
```bash
# Test single conversion
python -c "
from src.tts_tool import TTSProcessor
processor = TTSProcessor('speecht5')
audio = processor.generate_speech('Test', 'test.wav')
print('✅ Single conversion works!')
"

# Test batch processing
python -c "
from src.tts_tool import BatchTTSProcessor
processor = BatchTTSProcessor('speecht5')
results = processor.process_batch(['Hello', 'World'], 'test_output')
print(f'✅ Batch processing works! Processed {len(results)} items')
"
```

## 🚀 Deployment

### Quick Start Options

#### Option 1: Verify Setup (Recommended first step)
```bash
# Run setup verification
bash setup_verification.sh

# Or use Python validator
python deployment_validator.py
```

#### Option 2: Fast Deploy (5 minutes)
```bash
# Hugging Face Spaces (recommended for sharing)
cp -r deployment_configs/huggingface/* ./
git add . && git commit -m "Deploy TTS Tool" && git push origin main
```

#### Option 3: Local Development
```bash
# Clone and run
git clone https://github.com/yourusername/tts-tool.git
cd tts-tool
pip install -r requirements.txt
python main.py --web
```

### Comprehensive Deployment Guides

- **📋 Final Package Overview**: [FINAL_DEPLOYMENT_PACKAGE.md](FINAL_DEPLOYMENT_PACKAGE.md)
- **⚡ Quick Start Guide**: [QUICK_START_GUIDE.md](QUICK_START_GUIDE.md) - Deploy in 5-15 minutes
- **✅ Deployment Checklist**: [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) - Complete validation checklist
- **📊 Deployment Status**: [DEPLOYMENT_STATUS.md](DEPLOYMENT_STATUS.md) - Track deployment progress
- **🚀 Full Deployment Guide**: [DEPLOYMENT.md](DEPLOYMENT.md) - Comprehensive deployment instructions
- **📖 Step-by-Step Guide**: [DEPLOY_GUIDE.md](DEPLOY_GUIDE.md) - Detailed deployment procedures
- **🏭 Production Operations**: [production/README.md](production/README.md) - Production deployment and monitoring

### Cloud Platform Deployments

| Platform | Time | Difficulty | Best For | Guide |
|----------|------|------------|----------|-------|
| **Hugging Face Spaces** | 5 min | Easy | Quick demos & sharing | [HF Guide](DEPLOYMENT.md#hugging-face-spaces) |
| **Streamlit Cloud** | 10 min | Easy | Python web apps | [Streamlit Guide](DEPLOYMENT.md#streamlit-cloud) |
| **Render.com** | 15 min | Easy | Modern cloud deployment | [Render Guide](DEPLOYMENT.md#render) |
| **Docker Production** | 30 min | Medium | Full production stack | [Docker Guide](DEPLOYMENT.md#docker-deployment) |
| **AWS/GCP/Azure** | 60 min | Advanced | Enterprise deployment | [Cloud Guide](DEPLOYMENT.md#aws) |

### Deployment Verification

```bash
# 1. Verify system setup
bash setup_verification.sh

# 2. Validate configuration
python deployment_validator.py --verbose

# 3. Test basic functionality
python main.py --text "Test" --output test.wav

# 4. Test web interface
python main.py --web

# 5. Run comprehensive deployment checklist
# See DEPLOYMENT_CHECKLIST.md for complete list
```

### Production Deployment

For production environments with monitoring, scaling, and backup:

```bash
# Setup production environment
./production/scripts/setup-env.sh

# Deploy with full monitoring
./production/scripts/deploy.sh production latest

# Monitor with Grafana/Prometheus
# Access: http://localhost:3000 (Grafana)
# Access: http://localhost:9090 (Prometheus)
```

See [production/README.md](production/README.md) for complete production deployment guide.

## 📚 API Reference

### Core Classes

#### TTSProcessor
```python
class TTSProcessor:
    def __init__(self, model_name: str, device: str = "cpu")
    def generate_speech(self, text: str, output_path: str, **kwargs) -> str
    def get_model_info(self) -> dict
```

#### AdvancedTTSProcessor
```python
class AdvancedTTSProcessor:
    def __init__(self, model_name: str)
    def generate_with_emotion(self, text: str, emotion: str, output_path: str) -> str
    def set_speaker(self, speaker_id: str)
    def adjust_pace(self, text: str, speed_factor: float, output_path: str) -> str
```

#### BatchTTSProcessor
```python
class BatchTTSProcessor:
    def __init__(self, model_name: str, max_workers: int = 4)
    def process_batch(self, texts: List[str], output_dir: str, **kwargs) -> List[dict]
    def export_batch_summary(self, results: List[dict], output_path: str) -> str
```

#### AudioFormatConverter
```python
class AudioFormatConverter:
    def convert_format(self, input_path: str, output_path: str, target_format: str, **kwargs) -> bool
    def apply_audio_effects(self, input_path: str, output_path: str, **effects) -> bool
    def get_audio_info(self, audio_path: str) -> dict
```

### Command Line Interface

#### Global Options
```bash
python main.py [OPTIONS]
```

#### Web Interface
```bash
python main.py --web --port 7860 --share
```

#### Text Conversion
```bash
python main.py --text "Hello" --output hello.wav --model speecht5
```

#### Batch Processing
```bash
python main.py --batch texts.txt --output-dir output/ --workers 4
```

#### Audio Conversion
```bash
python main.py --convert-audio input.wav --format mp3 --bitrate 192k
```

## 🎯 Use Cases

### Content Creation
- **Audiobook Production**: Convert written content to audio
- **Video Voiceovers**: Generate professional voiceovers for videos
- **Podcast Generation**: Create podcast episodes from scripts
- **Presentation Audio**: Add audio to slide presentations

### Accessibility
- **Text Reading**: Help visually impaired users read text
- **Language Learning**: Pronunciation examples for language students
- **Educational Content**: Audio versions of learning materials

### Business Applications
- **Customer Service**: Automated voice responses
- **Voice Mail**: Generate professional voicemail greetings
- **Training Materials**: Convert training documents to audio
- **Marketing Content**: Create engaging audio advertisements

### Development
- **API Integration**: Integrate TTS into applications
- **Voice Assistants**: Build conversational interfaces
- **Chatbots**: Add speech capabilities to chatbots
- **Mobile Apps**: Speech functionality for mobile applications

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup
```bash
# Fork and clone repository
git clone https://github.com/yourusername/tts-tool.git
cd tts-tool

# Setup development environment
python -m venv venv
source venv/bin/activate
pip install -r requirements-dev.txt

# Install in development mode
pip install -e .

# Create feature branch
git checkout -b feature/amazing-feature

# Make changes and test
pytest
black src/
flake8 src/

# Commit and push
git commit -m "Add amazing feature"
git push origin feature/amazing-feature

# Create pull request
```

### Contribution Guidelines
- Follow PEP 8 style guidelines
- Write comprehensive tests
- Update documentation
- Add examples for new features
- Ensure backward compatibility

### Reporting Issues
- Use GitHub Issues for bug reports
- Include environment details
- Provide minimal reproduction steps
- Attach relevant logs and screenshots

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 TTS Tool Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 🙏 Acknowledgments

- **Microsoft**: SpeechT5 model and research
- **Meta AI**: MMS-TTS multilingual model
- **Suno AI**: Bark creative TTS model
- **Hugging Face**: Model hosting and transformers library
- **Gradio**: Web interface framework
- **PyTorch**: Deep learning framework
- **Community**: All contributors and users

## 📊 Project Statistics

![GitHub stars](https://img.shields.io/github/stars/yourusername/tts-tool.svg?style=social&label=Star)
![GitHub forks](https://img.shields.io/github/forks/yourusername/tts-tool.svg?style=social&label=Fork)

[![GitHub issues](https://img.shields.io/github/issues/yourusername/tts-tool)](https://github.com/yourusername/tts-tool/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/yourusername/tts-tool)](https://github.com/yourusername/tts-tool/pulls)
[![GitHub contributors](https://img.shields.io/github/contributors/yourusername/tts-tool)](https://github.com/yourusername/tts-tool/graphs/contributors)

## 📞 Support & Community

- **📧 Email**: support@tts-tool.com
- **💬 Discord**: [Join our community](https://discord.gg/tts-tool)
- **🐛 Bug Reports**: [GitHub Issues](https://github.com/yourusername/tts-tool/issues)
- **💡 Feature Requests**: [GitHub Discussions](https://github.com/yourusername/tts-tool/discussions)
- **📖 Documentation**: [Full Documentation](https://tts-tool.readthedocs.io/)
- **📚 Examples**: [Example Gallery](https://github.com/yourusername/tts-tool/examples)

---

<div align="center">

**Made with ❤️ by MiniMax Agent**

[⭐ Star this repo](https://github.com/yourusername/tts-tool) • [🐛 Report Bug](https://github.com/yourusername/tts-tool/issues) • [💡 Request Feature](https://github.com/yourusername/tts-tool/discussions)

</div>
