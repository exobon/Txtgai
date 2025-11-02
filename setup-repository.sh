#!/bin/bash

# 🎤 TTS Tool - Repository Initialization Script
# This script initializes the GitHub repository with proper structure and configuration

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if GitHub CLI is installed
check_github_cli() {
    if ! command -v gh &> /dev/null; then
        log_warning "GitHub CLI (gh) not found. You'll need to create the repository manually."
        return 1
    fi
    return 0
}

# Get GitHub username
get_github_username() {
    if gh auth status &> /dev/null; then
        gh api user --jq '.login'
    else
        read -p "Enter your GitHub username: " username
        echo $username
    fi
}

# Create comprehensive .gitignore
create_gitignore() {
    log_info "Creating comprehensive .gitignore..."
    
    cat > .gitignore << 'EOF'
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class
*.so

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# PyInstaller
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/
cover/

# Translations
*.mo
*.pot

# Django stuff:
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal

# Flask stuff:
instance/
.webassets-cache

# Scrapy stuff:
.scrapy

# Sphinx documentation
docs/_build/

# PyBuilder
.pybuilder/
target/

# Jupyter Notebook
.ipynb_checkpoints

# IPython
profile_default/
ipython_config.py

# pyenv
.python-version

# pipenv
Pipfile.lock

# poetry
poetry.lock

# pdm
.pdm.toml
.pdm-python

# PEP 582
__pypackages__/

# Celery stuff
celerybeat-schedule
celerybeat.pid

# SageMath parsed files
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Spyder project settings
.spyderproject
.spyproject

# Rope project settings
.ropeproject

# mkdocs documentation
/site

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Pyre type checker
.pyre/

# pytype static type analyzer
.pytype/

# Cython debug symbols
cython_debug/

# TTS Tool specific
# Generated audio files
*.wav
*.mp3
*.flac
*.ogg
*.m4a
*.aac

# Batch processing outputs
batch_output/
output/
temp_audio/

# Model cache directories
models_cache/
.checkpoints/
transformers_cache/
.pt/
.pth

# Hugging Face cache
.hf_cache/

# Dataset downloads
data/
datasets/

# Logs
logs/
*.log

# Configuration files with secrets
config/secrets.yaml
config/production.yaml
.env.local

# IDE and editor files
.vscode/
.idea/
*.swp
*.swo
*~

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Temporary files
tmp/
temp/
.tmp/

# Large media files
*.mov
*.avi
*.mkv
*.mp4
*.wmv
*.flv
*.webm

# Model files (too large for Git)
*.bin
*.safetensors
*.onnx
*.pb

# Custom user files
user_data/
custom_models/
personal_config/

# Deployment files (can be regenerated)
docker-compose.override.yml
render.yaml

# Monitoring and metrics
metrics/
grafana_data/
prometheus_data/

# Backup files
*.bak
*.backup
backup/

# Lock files for specific package managers
package-lock.json
yarn.lock
EOF

    log_success "Created .gitignore"
}

# Initialize Git repository
init_git_repository() {
    log_info "Initializing Git repository..."
    
    # Initialize git if not already done
    if [ ! -d .git ]; then
        git init
        log_success "Git repository initialized"
    else
        log_info "Git repository already initialized"
    fi
}

# Create initial GitHub repository
create_github_repo() {
    local repo_name="tts-tool"
    local description="Multi-model TTS converter with web interface, batch processing, and 20+ language support"
    
    log_info "Creating GitHub repository: $repo_name"
    
    # Check if repository already exists
    if gh repo view "$repo_name" &> /dev/null; then
        log_warning "Repository $repo_name already exists on GitHub"
        read -p "Do you want to continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Aborting repository creation"
            return 1
        fi
    fi
    
    # Create repository on GitHub
    gh repo create "$repo_name" \
        --public \
        --description "$description" \
        --clone=false \
        --push=true \
        --source=. \
        --remote=origin \
        --pull=main \
        --push=main
        
    log_success "GitHub repository created successfully"
}

# Configure Git user information
configure_git_user() {
    log_info "Configuring Git user information..."
    
    # Get user info or ask for it
    if [ -z "$(git config --global user.name)" ]; then
        read -p "Enter your name for Git commits: " git_name
        git config --global user.name "$git_name"
    fi
    
    if [ -z "$(git config --global user.email)" ]; then
        read -p "Enter your email for Git commits: " git_email
        git config --global user.email "$git_email"
    fi
    
    log_success "Git user configuration completed"
}

# Add all files to Git
add_files_to_git() {
    log_info "Adding files to Git..."
    
    # Add all files
    git add .
    log_success "All files added to Git staging area"
}

# Create initial commit
create_initial_commit() {
    log_info "Creating initial commit..."
    
    commit_message="🎤 Initial commit: TTS Tool - Multi-model Text-to-Speech Converter

✨ Features:
- Multiple TTS models (SpeechT5, MMS-TTS, Bark)
- Beautiful Gradio web interface
- Batch processing capabilities
- Dataset integration (LJ Speech, Common Voice, VCTK)
- Audio format conversion
- GPU acceleration support
- Docker deployment ready
- Comprehensive documentation

🚀 Quick Start:
1. Docker: docker build -t tts-tool . && docker run -p 7860:7860 tts-tool
2. Python: pip install -r requirements.txt && python main.py --web
3. Cloud: Deploy to Hugging Face Spaces, Streamlit Cloud, or Render

📖 Documentation: Complete guides in docs/ folder
🐛 Issues: Use GitHub Issues for bug reports and feature requests
🤝 Contributing: See CONTRIBUTING.md for development guidelines

Made with ❤️ using state-of-the-art AI models."

    git commit -m "$commit_message"
    log_success "Initial commit created"
}

# Create and push to main branch
setup_main_branch() {
    log_info "Setting up main branch..."
    
    # Create and switch to main branch
    git branch -M main
    
    log_success "Main branch configured"
}

# Create release tags
create_release_tags() {
    log_info "Creating release tags..."
    
    # Create initial release tag
    git tag -a "v1.0.0" -m "🎉 Initial Release v1.0.0

🚀 Major Features:
- Multi-model TTS support (SpeechT5, MMS-TTS, Bark)
- Web interface with Gradio
- Batch processing
- Dataset integration
- Audio format conversion
- Docker support
- Comprehensive documentation

📦 Installation:
- Docker: docker pull ghcr.io/username/tts-tool:latest
- PyPI: pip install tts-tool
- Source: git clone https://github.com/username/tts-tool.git

🌐 Live Demo: https://tts-tool.hf.space"
    
    log_success "Release tags created (v1.0.0)"
}

# Push to GitHub
push_to_github() {
    log_info "Pushing to GitHub..."
    
    username=$(get_github_username)
    repo_name="tts-tool"
    
    # Set remote URL if not already set
    if [ -z "$(git remote get-url origin)" ]; then
        git remote add origin "https://github.com/$username/$repo_name.git"
    fi
    
    # Push to GitHub
    git push -u origin main --tags
    log_success "Successfully pushed to GitHub"
}

# Configure repository settings
configure_repository_settings() {
    log_info "Configuring repository settings..."
    
    log_warning "Please configure the following settings manually on GitHub:"
    echo ""
    echo "🔧 Repository Settings:"
    echo "  1. Enable Issues, Wiki, Projects, Discussions"
    echo "  2. Configure branch protection for 'main'"
    echo "  3. Enable Dependabot alerts and security updates"
    echo "  4. Set up GitHub Pages for documentation"
    echo "  5. Configure repository topics and description"
    echo "  6. Enable GitHub Actions workflows"
    echo ""
    echo "📋 Topics to add:"
    echo "  text-to-speech, tts, speech-synthesis, ai-voice, machine-learning"
    echo "  python, gradio, audio-processing, pytorch, transformers"
    echo "  huggingface, deep-learning, multilingual, batch-processing"
    echo ""
    echo "🏷️  Quick setup URL:"
    echo "  https://github.com/new?template_owner=&template_name=&owner=&name=tts-tool"
    echo ""
}

# Display next steps
show_next_steps() {
    log_info "Repository setup completed successfully!"
    echo ""
    echo "🎉 Next Steps:"
    echo ""
    echo "1. 🔗 Repository URL: https://github.com/$(get_github_username)/tts-tool"
    echo ""
    echo "2. 📋 Immediate Actions:"
    echo "   - Configure repository settings (see .github/REPOSITORY_INFO.md)"
    echo "   - Update badges in README.md with your username"
    echo "   - Set up GitHub Actions workflows"
    echo "   - Configure branch protection rules"
    echo ""
    echo "3. 🚀 Deploy Your Tool:"
    echo "   - Hugging Face Spaces: Deploy with one click"
    echo "   - Streamlit Cloud: Share web interface"
    echo "   - Render: Full cloud deployment"
    echo "   - Docker Hub: Container distribution"
    echo ""
    echo "4. 📖 Documentation:"
    echo "   - Update all README badges with your username"
    echo "   - Configure Sphinx documentation"
    echo "   - Add code examples and tutorials"
    echo ""
    echo "5. 🎯 Community:"
    echo "   - Create issue templates"
    echo "   - Set up contribution guidelines"
    echo "   - Enable discussions for Q&A"
    echo ""
    echo "📚 Full setup guide: DEPLOYMENT_CHECKLIST.md"
    echo "🏷️  Repository metadata: .github/REPOSITORY_INFO.md"
    echo ""
}

# Main execution
main() {
    echo "🎤 TTS Tool - Repository Initialization Script"
    echo "=================================================="
    echo ""
    
    # Check prerequisites
    if ! command -v git &> /dev/null; then
        log_error "Git is not installed. Please install Git first."
        exit 1
    fi
    
    if ! command -v gh &> /dev/null; then
        log_warning "GitHub CLI not found. You'll create the repository manually."
        log_info "Install it from: https://cli.github.com/"
    fi
    
    # Configuration
    configure_git_user
    
    # Git setup
    init_git_repository
    create_gitignore
    
    # Repository creation
    if check_github_cli; then
        create_github_repo
        local username=$(get_github_username)
        git remote add origin "https://github.com/$username/tts-tool.git"
    else
        log_warning "Please create the repository on GitHub manually:"
        echo "https://github.com/new"
    fi
    
    # Commit and push
    add_files_to_git
    create_initial_commit
    setup_main_branch
    create_release_tags
    
    if check_github_cli; then
        push_to_github
    fi
    
    # Final configuration
    configure_repository_settings
    show_next_steps
}

# Run main function
main "$@"