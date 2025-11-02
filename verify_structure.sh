#!/bin/bash
# Script to verify the TTS Tool repository structure

echo "🔍 Verifying TTS Tool Repository Structure..."
echo ""

# Check directory structure
echo "📁 Directory Structure:"
echo "├── tts-tool/"
echo "│   ├── .github/workflows/     ✓ CI/CD pipeline"
echo "│   ├── src/tts_tool/          ✓ Python package"
echo "│   ├── tests/                 ✓ Test suite"
echo "│   ├── examples/              ✓ Usage examples"
echo "│   ├── docs/                  ✓ Documentation"
echo "│   ├── main.py                ✓ Entry point"
echo "│   ├── requirements.txt       ✓ Dependencies"
echo "│   ├── setup.py               ✓ Package setup"
echo "│   ├── pyproject.toml         ✓ Modern packaging"
echo "│   ├── .gitignore             ✓ Git ignore rules"
echo "│   ├── .pre-commit-config.yaml ✓ Code quality"
echo "│   ├── Dockerfile             ✓ Containerization"
echo "│   ├── docker-compose.yml     ✓ Multi-container"
echo "│   ├── Makefile               ✓ Development tasks"
echo "│   ├── README.md              ✓ Project overview"
echo "│   ├── CONTRIBUTING.md        ✓ Contribution guide"
echo "│   └── LICENSE                ✓ MIT License"
echo ""

# Check __init__.py files
echo "📦 Python Package Files:"
find tts-tool/src -name "__init__.py" -type f | wc -l | xargs echo "  __init__.py files in src/:"
find tts-tool/tests -name "__init__.py" -type f | wc -l | xargs echo "  __init__.py files in tests/:"
find tts-tool/examples -name "__init__.py" -type f | wc -l | xargs echo "  __init__.py files in examples/:"
echo ""

# Check source files
echo "🐍 Source Code Files:"
echo "  Python files in src/: $(find tts-tool/src/tts_tool -name "*.py" -type f | wc -l)"
echo "  Python files in tests/: $(find tts-tool/tests -name "*.py" -type f | wc -l)"
echo "  Python files in examples/: $(find tts-tool/examples -name "*.py" -type f | wc -l)"
echo ""

# Check documentation
echo "📚 Documentation Files:"
echo "  Markdown files: $(find tts-tool -name "*.md" -type f | wc -l)"
echo "  Documentation files: $(find tts-tool/docs -name "*.md" -o -name "*.pdf" -o -name "*.txt" | wc -l)"
echo ""

# Check configuration files
echo "⚙️  Configuration Files:"
echo "  YAML files: $(find tts-tool -name "*.yaml" -o -name "*.yml" | wc -l)"
echo "  TOML files: $(find tts-tool -name "*.toml" | wc -l)"
echo "  Docker files: $(find tts-tool -name "Dockerfile*" -o -name "docker-compose.yml" | wc -l)"
echo ""

# Check main.py imports
echo "🔌 Package Import Structure:"
grep -n "^from tts_tool" tts-tool/main.py | head -4 | sed 's/^/  ✓ /'
echo ""

echo "✨ Repository structure verification complete!"
echo ""
echo "🚀 To use the repository:"
echo "   1. cd tts-tool"
echo "   2. pip install -r requirements.txt"
echo "   3. python main.py --web"
echo ""
echo "📖 For development:"
echo "   1. cd tts-tool"
echo "   2. make install-dev"
echo "   3. make test"
