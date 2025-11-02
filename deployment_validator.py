#!/usr/bin/env python3
"""
TTS Tool Configuration Validator
Comprehensive configuration validation and testing tool
"""

import os
import sys
import json
import yaml
import argparse
import subprocess
import platform
import socket
import tempfile
import shutil
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple, Any

# Version information
VERSION = "1.0.0"
SCRIPT_NAME = "TTS Tool Configuration Validator"

# Color codes for output
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    PURPLE = '\033[0;35m'
    CYAN = '\033[0;36m'
    NC = '\033[0m'  # No Color

class ValidationResult:
    """Single validation result"""
    def __init__(self, category: str, name: str, status: str, message: str, details: str = ""):
        self.category = category
        self.name = name
        self.status = status  # PASS, FAIL, WARN, INFO
        self.message = message
        self.details = details
        self.timestamp = datetime.now()

class ConfigValidator:
    """Main configuration validator class"""
    
    def __init__(self, verbose: bool = False):
        self.verbose = verbose
        self.results: List[ValidationResult] = []
        self.checks_passed = 0
        self.checks_failed = 0
        self.checks_warnings = 0
        
    def print_header(self):
        """Print script header"""
        print(f"{Colors.PURPLE}{'='*80}{Colors.NC}")
        print(f"{Colors.PURPLE}                    {SCRIPT_NAME}{Colors.NC}")
        print(f"{Colors.PURPLE}{'='*80}{Colors.NC}")
        print(f"Version: {VERSION}")
        print(f"Python: {sys.version}")
        print(f"Platform: {platform.platform()}")
        print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print()
    
    def log_result(self, category: str, name: str, status: str, message: str, details: str = ""):
        """Log a validation result"""
        result = ValidationResult(category, name, status, message, details)
        self.results.append(result)
        
        # Update counters
        if status == "PASS":
            self.checks_passed += 1
            color = Colors.GREEN
        elif status == "FAIL":
            self.checks_failed += 1
            color = Colors.RED
        elif status == "WARN":
            self.checks_warnings += 1
            color = Colors.YELLOW
        else:
            color = Colors.BLUE
        
        print(f"{color}[{status:4}]{Colors.NC} {message}")
        if details and self.verbose:
            print(f"         {Colors.CYAN}Details: {details}{Colors.NC}")
    
    def section(self, title: str):
        """Print section header"""
        print(f"\n{Colors.CYAN}{'='*80}{Colors.NC}")
        print(f"{Colors.CYAN}{title}{Colors.NC}")
        print(f"{Colors.CYAN}{'='*80}{Colors.NC}\n")
    
    def validate_python_environment(self):
        """Validate Python environment"""
        self.section("PYTHON ENVIRONMENT")
        
        # Python version
        python_version = sys.version_info
        if python_version >= (3, 8):
            self.log_result("Python", "Version", "PASS", 
                          f"Python {python_version.major}.{python_version.minor}.{python_version.micro}")
        else:
            self.log_result("Python", "Version", "FAIL", 
                          f"Python {python_version.major}.{python_version.minor}.{python_version.micro} (3.8+ required)")
        
        # Virtual environment
        venv = os.environ.get('VIRTUAL_ENV') or os.environ.get('CONDA_DEFAULT_ENV')
        if venv:
            self.log_result("Python", "Virtual Environment", "PASS", f"Active: {venv}")
        else:
            self.log_result("Python", "Virtual Environment", "WARN", "No virtual environment detected")
        
        # pip version
        try:
            import pip
            from pip import __version__ as pip_version
            self.log_result("Python", "pip", "PASS", f"pip {pip_version}")
        except ImportError:
            self.log_result("Python", "pip", "FAIL", "pip not available")
    
    def validate_dependencies(self):
        """Validate required Python packages"""
        self.section("PYTHON DEPENDENCIES")
        
        required_packages = {
            'torch': 'PyTorch',
            'transformers': 'Transformers',
            'gradio': 'Gradio',
            'librosa': 'Librosa',
            'soundfile': 'SoundFile',
            'datasets': 'Datasets',
            'huggingface_hub': 'Hugging Face Hub',
            'numpy': 'NumPy',
            'scipy': 'SciPy',
            'tqdm': 'tqdm'
        }
        
        for package, description in required_packages.items():
            try:
                module = __import__(package)
                version = getattr(module, '__version__', 'unknown')
                self.log_result("Dependencies", package, "PASS", f"{description} v{version}")
            except ImportError:
                self.log_result("Dependencies", package, "FAIL", f"{description} not installed")
    
    def validate_system_resources(self):
        """Validate system resources"""
        self.section("SYSTEM RESOURCES")
        
        # CPU cores
        import multiprocessing
        cpu_count = multiprocessing.cpu_count()
        if cpu_count >= 4:
            self.log_result("System", "CPU Cores", "PASS", f"{cpu_count} cores (Good)")
        elif cpu_count >= 2:
            self.log_result("System", "CPU Cores", "WARN", f"{cpu_count} cores (Minimum)")
        else:
            self.log_result("System", "CPU Cores", "FAIL", f"{cpu_count} cores (Insufficient)")
        
        # Memory
        try:
            import psutil
            memory = psutil.virtual_memory()
            total_gb = memory.total / (1024**3)
            available_gb = memory.available / (1024**3)
            
            if total_gb >= 8:
                self.log_result("System", "Memory", "PASS", 
                              f"{total_gb:.1f}GB total, {available_gb:.1f}GB available")
            elif total_gb >= 4:
                self.log_result("System", "Memory", "WARN", 
                              f"{total_gb:.1f}GB total, {available_gb:.1f}GB available (4GB+ recommended)")
            else:
                self.log_result("System", "Memory", "FAIL", 
                              f"{total_gb:.1f}GB total (4GB minimum required)")
        except ImportError:
            self.log_result("System", "Memory", "WARN", "psutil not available for memory check")
        
        # Disk space
        try:
            disk_usage = shutil.disk_usage('.')
            free_gb = disk_usage.free / (1024**3)
            if free_gb >= 10:
                self.log_result("System", "Disk Space", "PASS", f"{free_gb:.1f}GB free")
            elif free_gb >= 5:
                self.log_result("System", "Disk Space", "WARN", f"{free_gb:.1f}GB free (10GB+ recommended)")
            else:
                self.log_result("System", "Disk Space", "FAIL", f"{free_gb:.1f}GB free (5GB minimum)")
        except Exception as e:
            self.log_result("System", "Disk Space", "WARN", f"Could not check disk space: {e}")
    
    def validate_gpu_support(self):
        """Validate GPU and CUDA support"""
        self.section("GPU AND ACCELERATION")
        
        # Check for NVIDIA GPU
        try:
            import torch
            if torch.cuda.is_available():
                gpu_count = torch.cuda.device_count()
                gpu_name = torch.cuda.get_device_name(0)
                memory_gb = torch.cuda.get_device_properties(0).total_memory / (1024**3)
                self.log_result("GPU", "NVIDIA CUDA", "PASS", 
                              f"{gpu_count} GPU(s): {gpu_name} ({memory_gb:.1f}GB)")
            else:
                self.log_result("GPU", "NVIDIA CUDA", "WARN", "CUDA not available (will use CPU)")
        except ImportError:
            self.log_result("GPU", "PyTorch", "FAIL", "PyTorch not installed")
        
        # Check Apple Silicon MPS (macOS)
        if platform.system() == "Darwin":
            try:
                import torch
                if hasattr(torch.backends, 'mps') and torch.backends.mps.is_available():
                    self.log_result("GPU", "Apple MPS", "PASS", "MPS acceleration available")
                else:
                    self.log_result("GPU", "Apple MPS", "WARN", "MPS acceleration not available")
            except:
                pass
    
    def validate_project_structure(self):
        """Validate project structure"""
        self.section("PROJECT STRUCTURE")
        
        required_files = [
            'main.py',
            'requirements.txt',
            'README.md'
        ]
        
        required_dirs = [
            'src',
            'src/tts_tool',
            'examples',
            'tests',
            'docs',
            'deployment_configs'
        ]
        
        for file_path in required_files:
            if Path(file_path).exists():
                self.log_result("Structure", f"File: {file_path}", "PASS", "Exists")
            else:
                self.log_result("Structure", f"File: {file_path}", "FAIL", "Missing")
        
        for dir_path in required_dirs:
            if Path(dir_path).is_dir():
                self.log_result("Structure", f"Directory: {dir_path}", "PASS", "Exists")
            else:
                self.log_result("Structure", f"Directory: {dir_path}", "FAIL", "Missing")
    
    def validate_configuration_files(self):
        """Validate configuration files"""
        self.section("CONFIGURATION FILES")
        
        # Check .env file
        env_file = Path('.env')
        if env_file.exists():
            self.log_result("Config", ".env file", "PASS", "Exists")
            
            # Check required environment variables
            required_vars = [
                'TTS_DEVICE',
                'TTS_CACHE_DIR',
                'TTS_WEB_PORT',
                'TTS_DEFAULT_MODEL'
            ]
            
            env_content = env_file.read_text()
            for var in required_vars:
                if f"{var}=" in env_content:
                    self.log_result("Config", f"Env var: {var}", "PASS", "Set")
                else:
                    self.log_result("Config", f"Env var: {var}", "WARN", "Not set")
        else:
            self.log_result("Config", ".env file", "WARN", "Not found (will use defaults)")
        
        # Check production config
        prod_config = Path('production/config/production.yml')
        if prod_config.exists():
            self.log_result("Config", "Production config", "PASS", "Exists")
            
            try:
                with open(prod_config) as f:
                    config = yaml.safe_load(f)
                if config:
                    self.log_result("Config", "Production config", "INFO", "Valid YAML format")
            except Exception as e:
                self.log_result("Config", "Production config", "FAIL", f"Invalid YAML: {e}")
        else:
            self.log_result("Config", "Production config", "WARN", "Not found")
        
        # Check Docker files
        dockerfile = Path('Dockerfile')
        if dockerfile.exists():
            self.log_result("Config", "Dockerfile", "PASS", "Exists")
        else:
            self.log_result("Config", "Dockerfile", "WARN", "Not found")
        
        compose_file = Path('docker-compose.yml')
        if compose_file.exists():
            self.log_result("Config", "docker-compose.yml", "PASS", "Exists")
        else:
            self.log_result("Config", "docker-compose.yml", "WARN", "Not found")
    
    def validate_deployment_configs(self):
        """Validate deployment configurations"""
        self.section("DEPLOYMENT CONFIGURATIONS")
        
        deployment_configs = {
            'deployment_configs/huggingface': 'Hugging Face Spaces',
            'deployment_configs/streamlit': 'Streamlit Cloud',
            'deployment_configs/docker': 'Docker Production',
            'deployment_configs/render': 'Render.com'
        }
        
        for config_path, description in deployment_configs.items():
            config_dir = Path(config_path)
            if config_dir.is_dir():
                file_count = len(list(config_dir.glob('*')))
                self.log_result("Deployment", description, "PASS", f"{file_count} files")
            else:
                self.log_result("Deployment", description, "FAIL", "Configuration missing")
    
    def validate_network_connectivity(self):
        """Validate network connectivity"""
        self.section("NETWORK CONNECTIVITY")
        
        # Check internet connectivity
        test_hosts = [
            ('8.8.8.8', 53, 'Google DNS'),
            ('github.com', 443, 'GitHub'),
            ('huggingface.co', 443, 'Hugging Face')
        ]
        
        for host, port, name in test_hosts:
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(3)
                result = sock.connect_ex((host, port))
                sock.close()
                
                if result == 0:
                    self.log_result("Network", name, "PASS", f"Connection successful")
                else:
                    self.log_result("Network", name, "WARN", f"Connection failed")
            except Exception as e:
                self.log_result("Network", name, "WARN", f"Error: {e}")
    
    def validate_application_functionality(self):
        """Validate application functionality"""
        self.section("APPLICATION FUNCTIONALITY")
        
        # Test main.py
        main_py = Path('main.py')
        if main_py.exists():
            self.log_result("Application", "main.py", "PASS", "Exists")
            
            # Test help command
            try:
                result = subprocess.run([sys.executable, 'main.py', '--help'], 
                                      capture_output=True, timeout=10)
                if result.returncode == 0:
                    self.log_result("Application", "main.py --help", "PASS", "Command works")
                else:
                    self.log_result("Application", "main.py --help", "FAIL", "Command failed")
            except Exception as e:
                self.log_result("Application", "main.py --help", "FAIL", f"Error: {e}")
        else:
            self.log_result("Application", "main.py", "FAIL", "Not found")
        
        # Test model listing
        try:
            result = subprocess.run([sys.executable, 'main.py', '--list-models'], 
                                  capture_output=True, timeout=15)
            if result.returncode == 0:
                self.log_result("Application", "List models", "PASS", "Command works")
            else:
                self.log_result("Application", "List models", "FAIL", "Command failed")
        except Exception as e:
            self.log_result("Application", "List models", "FAIL", f"Error: {e}")
        
        # Test imports
        src_init = Path('src/tts_tool/__init__.py')
        if src_init.exists():
            self.log_result("Application", "Source module", "PASS", "Module structure valid")
            
            try:
                # Test basic import
                import sys
                sys.path.insert(0, 'src')
                from tts_tool import TTSProcessor
                self.log_result("Application", "TTSProcessor import", "PASS", "Import successful")
            except Exception as e:
                self.log_result("Application", "TTSProcessor import", "FAIL", f"Import failed: {e}")
        else:
            self.log_result("Application", "Source module", "FAIL", "Module structure invalid")
    
    def validate_audio_system(self):
        """Validate audio system"""
        self.section("AUDIO SYSTEM")
        
        # Check FFmpeg
        try:
            result = subprocess.run(['ffmpeg', '-version'], 
                                  capture_output=True, timeout=5)
            if result.returncode == 0:
                version_line = result.stdout.decode().split('\n')[0]
                self.log_result("Audio", "FFmpeg", "PASS", version_line)
            else:
                self.log_result("Audio", "FFmpeg", "FAIL", "Command failed")
        except FileNotFoundError:
            self.log_result("Audio", "FFmpeg", "FAIL", "Not installed")
        except Exception as e:
            self.log_result("Audio", "FFmpeg", "WARN", f"Error: {e}")
        
        # Check audio libraries
        audio_libs = ['pydub', 'librosa', 'soundfile']
        for lib in audio_libs:
            try:
                __import__(lib)
                self.log_result("Audio", f"Python lib: {lib}", "PASS", "Available")
            except ImportError:
                self.log_result("Audio", f"Python lib: {lib}", "FAIL", "Not installed")
    
    def generate_report(self):
        """Generate validation report"""
        self.section("VALIDATION SUMMARY")
        
        total_checks = len(self.results)
        
        print(f"Total Checks: {total_checks}")
        print(f"{Colors.GREEN}Passed: {self.checks_passed}{Colors.NC}")
        print(f"{Colors.YELLOW}Warnings: {self.checks_warnings}{Colors.NC}")
        print(f"{Colors.RED}Failed: {self.checks_failed}{Colors.NC}")
        print()
        
        # Calculate success rate
        if total_checks > 0:
            success_rate = (self.checks_passed / total_checks) * 100
            print(f"Success Rate: {success_rate:.1f}%")
            
            if success_rate >= 90:
                status_color = Colors.GREEN
                status_text = "EXCELLENT"
                recommendation = "Your system is ready for TTS Tool deployment!"
            elif success_rate >= 75:
                status_color = Colors.YELLOW
                status_text = "GOOD"
                recommendation = "Your system is mostly ready. Address warnings for optimal performance."
            elif success_rate >= 60:
                status_color = Colors.YELLOW
                status_text = "FAIR"
                recommendation = "Your system has issues that should be addressed before deployment."
            else:
                status_color = Colors.RED
                status_text = "NEEDS ATTENTION"
                recommendation = "Your system has critical issues that must be resolved before deployment."
            
            print(f"{status_color}Overall Status: {status_text}{Colors.NC}")
            print(f"\nRecommendation: {recommendation}")
        
        # Next steps
        print(f"\n{Colors.PURPLE}Next Steps:{Colors.NC}")
        print(f"{Colors.BLUE}1. Review any FAIL or WARN messages above{Colors.NC}")
        print(f"{Colors.BLUE}2. Install missing dependencies if needed{Colors.NC}")
        print(f"{Colors.BLUE}3. Run this validator again to verify fixes{Colors.NC}")
        print(f"{Colors.BLUE}4. Check the deployment checklist: DEPLOYMENT_CHECKLIST.md{Colors.NC}")
        print(f"{Colors.BLUE}5. Follow the quick start guide: QUICK_START_GUIDE.md{Colors.NC}")
        
        # Save detailed report
        report_file = "config_validation_report.json"
        report_data = {
            "timestamp": datetime.now().isoformat(),
            "version": VERSION,
            "summary": {
                "total_checks": total_checks,
                "passed": self.checks_passed,
                "warnings": self.checks_warnings,
                "failed": self.checks_failed,
                "success_rate": success_rate if total_checks > 0 else 0
            },
            "results": [
                {
                    "category": r.category,
                    "name": r.name,
                    "status": r.status,
                    "message": r.message,
                    "details": r.details,
                    "timestamp": r.timestamp.isoformat()
                }
                for r in self.results
            ]
        }
        
        with open(report_file, 'w') as f:
            json.dump(report_data, f, indent=2)
        
        print(f"\n{Colors.CYAN}Detailed report saved to: {report_file}{Colors.NC}")
        
        return self.checks_failed == 0
    
    def run_all_validations(self):
        """Run all validation checks"""
        self.print_header()
        
        # Run all validation methods
        self.validate_python_environment()
        self.validate_dependencies()
        self.validate_system_resources()
        self.validate_gpu_support()
        self.validate_project_structure()
        self.validate_configuration_files()
        self.validate_deployment_configs()
        self.validate_network_connectivity()
        self.validate_application_functionality()
        self.validate_audio_system()
        
        # Generate report
        return self.generate_report()

def main():
    """Main function"""
    parser = argparse.ArgumentParser(
        description="TTS Tool Configuration Validator",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python deployment_validator.py              # Run all validations
  python deployment_validator.py --verbose    # Run with detailed output
  python deployment_validator.py --category   # Run only specific category
        """
    )
    
    parser.add_argument('--verbose', '-v', action='store_true',
                       help='Enable verbose output')
    parser.add_argument('--category', '-c', 
                       choices=['python', 'dependencies', 'system', 'gpu', 
                               'structure', 'config', 'deployment', 'network',
                               'application', 'audio'],
                       help='Run only specific validation category')
    parser.add_argument('--version', action='version',
                       version=f'{SCRIPT_NAME} v{VERSION}')
    
    args = parser.parse_args()
    
    # Create validator
    validator = ConfigValidator(verbose=args.verbose)
    
    if args.category:
        # Run specific category
        validator.print_header()
        category_methods = {
            'python': validator.validate_python_environment,
            'dependencies': validator.validate_dependencies,
            'system': validator.validate_system_resources,
            'gpu': validator.validate_gpu_support,
            'structure': validator.validate_project_structure,
            'config': validator.validate_configuration_files,
            'deployment': validator.validate_deployment_configs,
            'network': validator.validate_network_connectivity,
            'application': validator.validate_application_functionality,
            'audio': validator.validate_audio_system
        }
        
        method = category_methods.get(args.category)
        if method:
            method()
            validator.generate_report()
        else:
            print(f"Error: Unknown category '{args.category}'")
            sys.exit(1)
    else:
        # Run all validations
        success = validator.run_all_validations()
        sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()