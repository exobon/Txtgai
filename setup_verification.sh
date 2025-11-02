#!/bin/bash

# TTS Tool Setup Verification Script
# Comprehensive setup validation and health check

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="TTS Tool Setup Verification"
LOG_FILE="setup_verification.log"

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    local color
    
    case $status in
        "PASS")
            color=$GREEN
            ((PASSED_CHECKS++))
            ;;
        "FAIL")
            color=$RED
            ((FAILED_CHECKS++))
            ;;
        "WARN")
            color=$YELLOW
            ((WARNING_CHECKS++))
            ;;
        "INFO")
            color=$BLUE
            ;;
        *)
            color=$NC
            ;;
    esac
    
    echo -e "${color}[$status]${NC} $message"
    ((TOTAL_CHECKS++))
    
    # Log to file
    echo "[$status] $message" >> "$LOG_FILE"
}

print_header() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                              ║"
    echo "║                    $SCRIPT_NAME                                    ║"
    echo "║                                                                              ║"
    echo "║                          Version $SCRIPT_VERSION                                 ║"
    echo "║                                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo "Starting comprehensive setup verification..."
    echo "Log file: $LOG_FILE"
    echo ""
}

print_section() {
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if file exists
file_exists() {
    [[ -f "$1" ]]
}

# Function to check if directory exists
dir_exists() {
    [[ -d "$1" ]]
}

# Function to run a test command safely
safe_run() {
    if "$@" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 1. System Requirements Check
check_system_requirements() {
    print_section "SYSTEM REQUIREMENTS"
    
    # Check operating system
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="Linux"
        OS_VERSION=$(lsb_release -d 2>/dev/null | cut -f2 || uname -r)
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macOS"
        OS_VERSION=$(sw_vers -productVersion 2>/dev/null || uname -r)
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        OS="Windows"
        OS_VERSION="Windows"
    else
        OS="Unknown"
        OS_VERSION="Unknown"
    fi
    
    if [[ "$OS" != "Unknown" ]]; then
        print_status "PASS" "Operating System: $OS $OS_VERSION"
    else
        print_status "FAIL" "Operating System: Unknown ($OSTYPE)"
    fi
    
    # Check architecture
    ARCH=$(uname -m 2>/dev/null || echo "unknown")
    print_status "PASS" "System Architecture: $ARCH"
    
    # Check available memory
    if command_exists free; then
        TOTAL_MEM=$(free -m | awk 'NR==2{printf "%.1f", $2/1024}')
        AVAILABLE_MEM=$(free -m | awk 'NR==2{printf "%.1f", $7/1024}')
        
        if (( $(echo "$TOTAL_MEM >= 4" | bc -l) )); then
            print_status "PASS" "Total Memory: ${TOTAL_MEM}GB (Available: ${AVAILABLE_MEM}GB)"
        elif (( $(echo "$TOTAL_MEM >= 2" | bc -l) )); then
            print_status "WARN" "Total Memory: ${TOTAL_MEM}GB (Minimum 4GB recommended, Available: ${AVAILABLE_MEM}GB)"
        else
            print_status "FAIL" "Total Memory: ${TOTAL_MEM}GB (Minimum 2GB required, Available: ${AVAILABLE_MEM}GB)"
        fi
    elif command_exists vm_stat; then
        # macOS
        TOTAL_MEM=$(($(sysctl -n hw.memsize) / 1073741824))
        print_status "PASS" "Total Memory: ${TOTAL_MEM}GB (macOS)"
    else
        print_status "WARN" "Memory check not available on this system"
    fi
    
    # Check disk space
    DISK_USAGE=$(df -h . | awk 'NR==2 {print $5}' | sed 's/%//')
    DISK_AVAILABLE=$(df -h . | awk 'NR==2 {print $4}')
    
    if [[ $DISK_USAGE -lt 80 ]]; then
        print_status "PASS" "Disk Space: ${DISK_USAGE}% used (Available: ${DISK_AVAILABLE})"
    elif [[ $DISK_USAGE -lt 90 ]]; then
        print_status "WARN" "Disk Space: ${DISK_USAGE}% used (Consider cleanup, Available: ${DISK_AVAILABLE})"
    else
        print_status "FAIL" "Disk Space: ${DISK_USAGE}% used (Critical, Available: ${DISK_AVAILABLE})"
    fi
    
    # Check internet connectivity
    if safe_run ping -c 1 google.com >/dev/null 2>&1; then
        print_status "PASS" "Internet Connectivity: Available"
    else
        print_status "FAIL" "Internet Connectivity: Not available"
    fi
}

# 2. Python Environment Check
check_python_environment() {
    print_section "PYTHON ENVIRONMENT"
    
    # Check Python installation
    if command_exists python3; then
        PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
        PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d'.' -f1)
        PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d'.' -f2)
        
        if [[ $PYTHON_MAJOR -eq 3 && $PYTHON_MINOR -ge 8 ]]; then
            print_status "PASS" "Python 3.x found: $PYTHON_VERSION"
        else
            print_status "FAIL" "Python version too old: $PYTHON_VERSION (3.8+ required)"
        fi
    else
        print_status "FAIL" "Python 3 not found"
    fi
    
    # Check pip
    if command_exists pip3 || command_exists pip; then
        PIP_CMD="pip3"
        if ! command_exists pip3; then
            PIP_CMD="pip"
        fi
        PIP_VERSION=$($PIP_CMD --version 2>&1 | cut -d' ' -f2)
        print_status "PASS" "pip found: version $PIP_VERSION"
    else
        print_status "FAIL" "pip not found"
    fi
    
    # Check virtual environment
    if [[ "$VIRTUAL_ENV" != "" ]]; then
        print_status "PASS" "Virtual Environment: Active ($VIRTUAL_ENV)"
    else
        print_status "WARN" "Virtual Environment: Not active (recommended for isolation)"
    fi
    
    # Check Python path
    PYTHON_PATH=$(which python3 2>/dev/null || which python 2>/dev/null || echo "not found")
    print_status "PASS" "Python Executable: $PYTHON_PATH"
}

# 3. Core Dependencies Check
check_core_dependencies() {
    print_section "CORE DEPENDENCIES"
    
    # Check if we can import core modules
    python3 -c "
import sys
modules = [
    'torch', 'transformers', 'gradio', 'librosa', 
    'soundfile', 'datasets', 'huggingface_hub'
]

failed = []
for module in modules:
    try:
        __import__(module)
        print(f'PASS|{module}')
    except ImportError:
        print(f'FAIL|{module}')

if failed:
    sys.exit(1)
" 2>/dev/null | while IFS='|' read -r status module; do
        if [[ "$status" == "PASS" ]]; then
            print_status "PASS" "Python module: $module"
        else
            print_status "FAIL" "Python module: $module (not installed)"
        fi
    done
}

# 4. Audio System Check
check_audio_system() {
    print_section "AUDIO SYSTEM"
    
    # Check FFmpeg
    if command_exists ffmpeg; then
        FFMPEG_VERSION=$(ffmpeg -version 2>&1 | head -n1 | cut -d' ' -f3)
        print_status "PASS" "FFmpeg installed: $FFFMPEG_VERSION"
    else
        print_status "FAIL" "FFmpeg not found (required for audio processing)"
    fi
    
    # Check PortAudio
    if python3 -c "import pyaudio" 2>/dev/null; then
        print_status "PASS" "PortAudio/PyAudio installed"
    else
        print_status "WARN" "PortAudio/PyAudio not installed (audio playback may not work)"
    fi
    
    # Check audio devices (Linux)
    if [[ "$OSTYPE" == "linux-gnu"* ]] && command_exists aplay; then
        if safe_run aplay -l >/dev/null 2>&1; then
            print_status "PASS" "ALSA audio devices available"
        else
            print_status "WARN" "ALSA audio devices not available"
        fi
    fi
    
    # Check sound system (macOS)
    if [[ "$OSTYPE" == "darwin"* ]] && command_exists system_profiler; then
        if safe_run system_profiler SPAudioDataType >/dev/null 2>&1; then
            print_status "PASS" "macOS audio system available"
        else
            print_status "WARN" "macOS audio system not available"
        fi
    fi
}

# 5. Project Structure Check
check_project_structure() {
    print_section "PROJECT STRUCTURE"
    
    # Check required files
    required_files=(
        "main.py"
        "requirements.txt"
        "README.md"
        "src/tts_tool/__init__.py"
        "src/tts_tool/tts_processor.py"
    )
    
    for file in "${required_files[@]}"; do
        if file_exists "$file"; then
            print_status "PASS" "File exists: $file"
        else
            print_status "FAIL" "File missing: $file"
        fi
    done
    
    # Check directory structure
    required_dirs=(
        "src"
        "src/tts_tool"
        "examples"
        "tests"
        "docs"
        "deployment_configs"
        "production"
    )
    
    for dir in "${required_dirs[@]}"; do
        if dir_exists "$dir"; then
            print_status "PASS" "Directory exists: $dir"
        else
            print_status "FAIL" "Directory missing: $dir"
        fi
    done
    
    # Check deployment configurations
    deployment_configs=(
        "deployment_configs/huggingface"
        "deployment_configs/streamlit"
        "deployment_configs/docker"
        "deployment_configs/render"
    )
    
    for config in "${deployment_configs[@]}"; do
        if dir_exists "$config"; then
            print_status "PASS" "Deployment config: $config"
        else
            print_status "FAIL" "Deployment config missing: $config"
        fi
    done
}

# 6. Configuration Files Check
check_configuration_files() {
    print_section "CONFIGURATION FILES"
    
    # Check environment file
    if file_exists ".env"; then
        print_status "PASS" "Environment file (.env) exists"
        
        # Check for required variables
        required_vars=("TTS_DEVICE" "TTS_CACHE_DIR" "TTS_WEB_PORT")
        for var in "${required_vars[@]}"; do
            if grep -q "^$var=" .env 2>/dev/null; then
                print_status "PASS" "Environment variable: $var"
            else
                print_status "WARN" "Environment variable missing: $var"
            fi
        done
    else
        print_status "WARN" "Environment file (.env) not found (will use defaults)"
    fi
    
    # Check production config
    if file_exists "production/config/production.yml"; then
        print_status "PASS" "Production configuration exists"
    else
        print_status "WARN" "Production configuration not found"
    fi
    
    # Check docker configs
    if file_exists "Dockerfile"; then
        print_status "PASS" "Dockerfile exists"
    else
        print_status "WARN" "Dockerfile not found"
    fi
    
    if file_exists "docker-compose.yml"; then
        print_status "PASS" "docker-compose.yml exists"
    else
        print_status "WARN" "docker-compose.yml not found"
    fi
}

# 7. Git Repository Check
check_git_repository() {
    print_section "GIT REPOSITORY"
    
    if dir_exists ".git"; then
        print_status "PASS" "Git repository initialized"
        
        # Check remote origin
        if git remote get-url origin >/dev/null 2>&1; then
            REMOTE_URL=$(git remote get-url origin)
            print_status "PASS" "Remote origin configured: $REMOTE_URL"
        else
            print_status "WARN" "No remote origin configured"
        fi
        
        # Check current branch
        CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
        print_status "PASS" "Current branch: $CURRENT_BRANCH"
        
        # Check for uncommitted changes
        if git diff-index --quiet HEAD -- 2>/dev/null; then
            print_status "PASS" "No uncommitted changes"
        else
            print_status "WARN" "Uncommitted changes detected"
        fi
        
        # Check for remote changes
        if git fetch origin >/dev/null 2>&1; then
            LOCAL_HASH=$(git rev-parse HEAD 2>/dev/null)
            REMOTE_HASH=$(git rev-parse origin/$CURRENT_BRANCH 2>/dev/null)
            
            if [[ "$LOCAL_HASH" == "$REMOTE_HASH" ]]; then
                print_status "PASS" "Repository is up to date"
            else
                print_status "WARN" "Local repository is behind remote"
            fi
        fi
    else
        print_status "WARN" "Not a git repository"
    fi
}

# 8. GPU and Performance Check
check_gpu_performance() {
    print_section "GPU AND PERFORMANCE"
    
    # Check NVIDIA GPU
    if command_exists nvidia-smi; then
        if safe_run nvidia-smi >/dev/null 2>&1; then
            GPU_INFO=$(nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits 2>/dev/null | head -n1)
            print_status "PASS" "NVIDIA GPU detected: $GPU_INFO"
            
            # Check CUDA
            if python3 -c "import torch; print(torch.version.cuda)" 2>/dev/null | grep -q "[0-9]"; then
                CUDA_VERSION=$(python3 -c "import torch; print(torch.version.cuda)" 2>/dev/null)
                print_status "PASS" "CUDA available: version $CUDA_VERSION"
            else
                print_status "WARN" "CUDA not available in PyTorch"
            fi
        else
            print_status "WARN" "NVIDIA GPU detected but not accessible"
        fi
    else
        print_status "WARN" "NVIDIA GPU not detected or drivers not installed"
    fi
    
    # Check Apple Silicon (macOS)
    if [[ "$OSTYPE" == "darwin"* ]] && sysctl -n machdep.cpu.brand_string 2>/dev/null | grep -q "Apple"; then
        if python3 -c "import torch; print('MPS available:', torch.backends.mps.is_available())" 2>/dev/null | grep -q "True"; then
            print_status "PASS" "Apple Silicon MPS acceleration available"
        else
            print_status "WARN" "Apple Silicon MPS acceleration not available"
        fi
    fi
    
    # Check CPU cores
    CPU_CORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "1")
    if [[ $CPU_CORES -ge 4 ]]; then
        print_status "PASS" "CPU Cores: $CPU_CORES (Good for parallel processing)"
    elif [[ $CPU_CORES -ge 2 ]]; then
        print_status "WARN" "CPU Cores: $CPU_CORES (Minimum for basic operation)"
    else
        print_status "FAIL" "CPU Cores: $CPU_CORES (Insufficient for TTS processing)"
    fi
}

# 9. Application Functionality Check
check_application_functionality() {
    print_section "APPLICATION FUNCTIONALITY"
    
    # Check if main.py is executable
    if file_exists "main.py"; then
        print_status "PASS" "main.py exists"
        
        # Test help command
        if safe_run python3 main.py --help >/dev/null 2>&1; then
            print_status "PASS" "main.py help command works"
        else
            print_status "FAIL" "main.py help command failed"
        fi
        
        # Test list models
        if safe_run python3 main.py --list-models >/dev/null 2>&1; then
            print_status "PASS" "Model listing works"
        else
            print_status "FAIL" "Model listing failed"
        fi
    else
        print_status "FAIL" "main.py not found"
    fi
    
    # Test TTS module imports
    if safe_run python3 -c "from src.tts_tool import TTSProcessor" >/dev/null 2>&1; then
        print_status "PASS" "TTSProcessor module imports successfully"
    else
        print_status "FAIL" "TTSProcessor module import failed"
    fi
    
    if safe_run python3 -c "from src.tts_tool import create_interface" >/dev/null 2>&1; then
        print_status "PASS" "Interface creation module imports successfully"
    else
        print_status "FAIL" "Interface creation module import failed"
    fi
}

# 10. Network and Security Check
check_network_security() {
    print_section "NETWORK AND SECURITY"
    
    # Check firewall status
    if command_exists ufw; then
        UFW_STATUS=$(ufw status 2>/dev/null | head -n1 | cut -d':' -f2 | xargs)
        print_status "PASS" "UFW Firewall: $UFW_STATUS"
    elif command_exists firewall-cmd; then
        if safe_run firewall-cmd --state >/dev/null 2>&1; then
            print_status "PASS" "firewalld is running"
        else
            print_status "WARN" "firewalld is not running"
        fi
    else
        print_status "WARN" "Firewall management tool not found"
    fi
    
    # Check SSL/TLS support
    if command_exists openssl; then
        OPENSSL_VERSION=$(openssl version 2>/dev/null | cut -d' ' -f2)
        print_status "PASS" "OpenSSL installed: $OPENSSL_VERSION"
    else
        print_status "WARN" "OpenSSL not found"
    fi
    
    # Check proxy settings
    if [[ -z "$HTTP_PROXY" && -z "$HTTPS_PROXY" ]]; then
        print_status "PASS" "No proxy configured (direct connection)"
    else
        print_status "WARN" "Proxy configured (HTTP_PROXY or HTTPS_PROXY set)"
    fi
}

# Summary and recommendations
print_summary() {
    print_section "VERIFICATION SUMMARY"
    
    echo -e "${CYAN}Total Checks: $TOTAL_CHECKS${NC}"
    echo -e "${GREEN}Passed: $PASSED_CHECKS${NC}"
    echo -e "${YELLOW}Warnings: $WARNING_CHECKS${NC}"
    echo -e "${RED}Failed: $FAILED_CHECKS${NC}"
    echo ""
    
    # Calculate success rate
    SUCCESS_RATE=$(( (PASSED_CHECKS * 100) / TOTAL_CHECKS ))
    
    if [[ $SUCCESS_RATE -ge 90 ]]; then
        echo -e "${GREEN}✅ Overall Status: EXCELLENT ($SUCCESS_RATE%)${NC}"
        RECOMMENDATION="Your system is ready for TTS Tool deployment!"
    elif [[ $SUCCESS_RATE -ge 75 ]]; then
        echo -e "${YELLOW}⚠️  Overall Status: GOOD ($SUCCESS_RATE%)${NC}"
        RECOMMENDATION="Your system is mostly ready. Address warnings for optimal performance."
    elif [[ $SUCCESS_RATE -ge 60 ]]; then
        echo -e "${YELLOW}⚠️  Overall Status: FAIR ($SUCCESS_RATE%)${NC}"
        RECOMMENDATION="Your system has some issues that should be addressed before deployment."
    else
        echo -e "${RED}❌ Overall Status: NEEDS ATTENTION ($SUCCESS_RATE%)${NC}"
        RECOMMENDATION="Your system has critical issues that must be resolved before deployment."
    fi
    
    echo ""
    echo -e "${CYAN}Recommendation: $RECOMMENDATION${NC}"
    echo ""
    
    # Next steps
    echo -e "${PURPLE}Next Steps:${NC}"
    echo -e "${BLUE}1. Review any FAIL or WARN messages above${NC}"
    echo -e "${BLUE}2. Install missing dependencies if needed${NC}"
    echo -e "${BLUE}3. Run this script again to verify fixes${NC}"
    echo -e "${BLUE}4. Check the deployment checklist: DEPLOYMENT_CHECKLIST.md${NC}"
    echo -e "${BLUE}5. Follow the quick start guide: QUICK_START_GUIDE.md${NC}"
    echo ""
    
    # Create output file with results
    cat > setup_verification_report.txt << EOF
TTS Tool Setup Verification Report
Generated: $(date)
Version: $SCRIPT_VERSION

SUMMARY:
Total Checks: $TOTAL_CHECKS
Passed: $PASSED_CHECKS
Warnings: $WARNING_CHECKS
Failed: $FAILED_CHECKS
Success Rate: $SUCCESS_RATE%

RECOMMENDATION:
$RECOMMENDATION

DETAILED LOG:
See $LOG_FILE for complete verification log.

NEXT STEPS:
1. Address any FAIL or WARN messages
2. Install missing dependencies
3. Run verification again
4. Follow deployment guides
EOF
    
    echo -e "${CYAN}Detailed report saved to: setup_verification_report.txt${NC}"
    echo -e "${CYAN}Log file: $LOG_FILE${NC}"
}

# Main execution
main() {
    # Initialize log file
    echo "TTS Tool Setup Verification Log - $(date)" > "$LOG_FILE"
    echo "=================================================" >> "$LOG_FILE"
    
    print_header
    
    # Run all checks
    check_system_requirements
    check_python_environment
    check_core_dependencies
    check_audio_system
    check_project_structure
    check_configuration_files
    check_git_repository
    check_gpu_performance
    check_application_functionality
    check_network_security
    
    # Print summary
    print_summary
    
    # Exit with appropriate code
    if [[ $FAILED_CHECKS -gt 0 ]]; then
        exit 1
    elif [[ $WARNING_CHECKS -gt 0 ]]; then
        exit 2
    else
        exit 0
    fi
}

# Handle command line arguments
case "${1:-}" in
    "--help"|"-h")
        echo "TTS Tool Setup Verification Script"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --version, -v  Show version information"
        echo "  --quick        Run quick checks only"
        echo "  --detailed     Run all checks (default)"
        echo ""
        echo "This script verifies that your system is ready for TTS Tool deployment."
        exit 0
        ;;
    "--version"|"-v")
        echo "$SCRIPT_NAME Version $SCRIPT_VERSION"
        exit 0
        ;;
    "--quick")
        echo "Running quick verification..."
        # Run only essential checks
        check_system_requirements
        check_python_environment
        check_core_dependencies
        check_application_functionality
        print_summary
        ;;
    *)
        main
        ;;
esac