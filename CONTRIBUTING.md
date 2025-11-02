# Contributing to TTS Repository

Thank you for your interest in contributing to the TTS (Text-to-Speech) repository! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Coding Guidelines](#coding-guidelines)
- [Testing](#testing)
- [Documentation](#documentation)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

Please note that this project adheres to a Code of Conduct. By participating, you are expected to uphold this code. See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for details.

## How to Contribute

We welcome contributions in various forms:

- 🐛 **Bug Reports**: Report bugs through GitHub Issues
- 💡 **Feature Requests**: Suggest new features or improvements
- 🔧 **Code Contributions**: Submit bug fixes, new features, or improvements
- 📚 **Documentation**: Improve documentation, examples, or tutorials
- 🧪 **Testing**: Add or improve test coverage
- 🎨 **UI/UX**: Improve the Gradio interface or user experience

## Development Setup

### Prerequisites

- Python 3.8 or higher
- pip or conda package manager
- Git

### Setup Instructions

1. **Fork the repository**
   ```bash
   git clone https://github.com/yourusername/tts-repo.git
   cd tts-repo
   ```

2. **Create a virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Install development dependencies**
   ```bash
   pip install -r requirements-dev.txt
   ```

5. **Set up pre-commit hooks** (optional but recommended)
   ```bash
   pre-commit install
   ```

## Coding Guidelines

### Python Style

- Follow [PEP 8](https://pep8.org/) style guidelines
- Use type hints where appropriate
- Write descriptive docstrings for all functions and classes
- Maximum line length: 88 characters (Black formatter default)

### Code Organization

- Keep code modular and reusable
- Place new features in appropriate modules under `code/`
- Follow the existing project structure
- Use meaningful variable and function names

### Documentation

- Document all public APIs
- Include docstrings for all functions and classes
- Update documentation when adding new features
- Use clear, concise language

## Testing

### Running Tests

```bash
# Run all tests
pytest tests/

# Run tests with coverage
pytest tests/ --cov=code --cov-report=html

# Run specific test file
pytest tests/test_tts_processor.py
```

### Writing Tests

- Write tests for all new features and bug fixes
- Follow the existing test structure in `tests/`
- Use descriptive test names that explain what is being tested
- Aim for good test coverage

### Test Categories

- **Unit Tests**: Test individual functions and classes
- **Integration Tests**: Test interactions between components
- **E2E Tests**: Test complete workflows and user interfaces

## Documentation

### Types of Documentation

- **API Documentation**: Generated from docstrings
- **User Guides**: Step-by-step instructions for end users
- **Developer Documentation**: Technical details for contributors
- **Examples**: Code samples and tutorials

### Documentation Standards

- Keep documentation up to date with code changes
- Use clear, concise language
- Include code examples where helpful
- Add diagrams or visual aids when appropriate

## Pull Request Process

### Before Submitting

1. **Update your fork**
   ```bash
   git remote add upstream https://github.com/original/tts-repo.git
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run tests and linting**
   ```bash
   pytest tests/
   black --check code/
   flake8 code/
   ```

3. **Update documentation** if needed

### PR Guidelines

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following the coding guidelines

3. **Write tests** for your changes

4. **Update documentation** if necessary

5. **Run the full test suite** to ensure nothing is broken

6. **Commit with clear messages**
   ```bash
   git commit -m "Add feature: short description"
   ```

7. **Push and create PR**
   ```bash
   git push origin feature/your-feature-name
   ```

### PR Description Template

```
## Description
Brief description of changes made

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tests pass locally
- [ ] Added/updated tests for changes
- [ ] Manual testing performed

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings introduced
```

### Review Process

1. **Automated Checks**: All PRs must pass CI/CD checks
2. **Code Review**: At least one maintainer review required
3. **Testing**: Changes should not break existing functionality
4. **Documentation**: Ensure documentation is updated if needed

## Additional Resources

- [GitHub Flow](https://docs.github.com/en/get-started/using-github/github-flow)
- [Git Documentation](https://git-scm.com/doc)
- [Python Documentation](https://docs.python.org/3/)
- [Project Issues](https://github.com/username/tts-repo/issues)

## Questions?

If you have questions about contributing, please:

1. Check existing [Issues](https://github.com/username/tts-repo/issues)
2. Create a new Issue with the "question" label
3. Join our community discussions

Thank you for contributing to the TTS Repository! 🎉