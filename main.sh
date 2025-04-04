#!/bin/bash
# ElysianLens: An Elegant Web Data Harvesting & Analysis Platform
# Version 1.0.0
# 
# This script sets up the complete ElysianLens environment,
# a sophisticated data extraction and analysis platform
# designed to showcase advanced software engineering skills.

set -e

# ANSI color codes for beautiful terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
RESET='\033[0m'

# ElysianLens ASCII art
LOGO="
${CYAN}${BOLD}
    ███████╗██╗  ██╗   ██╗███████╗██╗ █████╗ ███╗   ██╗
    ██╔════╝██║  ╚██╗ ██╔╝██╔════╝██║██╔══██╗████╗  ██║
    █████╗  ██║   ╚████╔╝ ███████╗██║███████║██╔██╗ ██║
    ██╔══╝  ██║    ╚██╔╝  ╚════██║██║██╔══██║██║╚██╗██║
    ███████╗███████╗██║   ███████║██║██║  ██║██║ ╚████║
    ╚══════╝╚══════╝╚═╝   ╚══════╝╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝
                                                     
    ██╗     ███████╗███╗   ██╗███████╗                 
    ██║     ██╔════╝████╗  ██║██╔════╝                 
    ██║     █████╗  ██╔██╗ ██║███████╗                 
    ██║     ██╔══╝  ██║╚██╗██║╚════██║                 
    ███████╗███████╗██║ ╚████║███████║                 
    ╚══════╝╚══════╝╚═╝  ╚═══╝╚══════╝                 
${RESET}
${MAGENTA}${BOLD}The Elegant Web Data Harvesting & Analysis Platform${RESET}
${BLUE}Version 1.0.0${RESET}
"

LLAMA_ANIMATION=(
"${CYAN}  ${BOLD}🦙${RESET}"
"${CYAN}   ${BOLD}🦙${RESET}"
"${CYAN}    ${BOLD}🦙${RESET}"
"${CYAN}     ${BOLD}🦙${RESET}"
"${CYAN}      ${BOLD}🦙${RESET}"
"${CYAN}     ${BOLD}🦙${RESET}"
"${CYAN}    ${BOLD}🦙${RESET}"
"${CYAN}   ${BOLD}🦙${RESET}"
)

CONFIG_DIR="$HOME/.elysian_lens"
INSTALL_DIR="$CONFIG_DIR/elysian_lens"
ENV_FILE="$CONFIG_DIR/.env"
LOG_DIR="$CONFIG_DIR/logs"
DATA_DIR="$CONFIG_DIR/data"
MODELS_DIR="$CONFIG_DIR/models"
PROXY_FILE="$CONFIG_DIR/proxies.json"
API_KEYS_FILE="$CONFIG_DIR/api_keys.json"

# Required tools and dependencies
REQUIRED_TOOLS=(
    "python3"
    "pip3"
    "git"
    "curl"
    "brew"
)

# Python packages to install
PYTHON_PACKAGES=(
    "fastapi==0.103.1"
    "uvicorn[standard]==0.23.2"
    "pydantic==2.3.0"
    "python-dotenv==1.0.0"
    "rich==13.5.3"
    "typer==0.9.0"
    "playwright==1.38.0"
    "requests==2.31.0"
    "beautifulsoup4==4.12.2"
    "aiohttp==3.8.5"
    "httpx==0.25.0"
    "numpy==1.26.0"
    "pandas==2.1.1"
    "pillow==10.0.1"
    "openai==1.2.0"
    "anthropic==0.5.0"
    "transformers==4.34.0"
    "qdrant-client==1.5.4"
    "sqlite-utils==3.35.1"
    "llama-index==0.8.54"
    "scikit-learn==1.3.0"
    "markdownify==0.11.6"
    "pytest==7.4.2"
    "scrapy==2.11.0"
    "selenium==4.11.2"
    "pyppeteer==1.0.2"
    "cloudscraper==1.2.71"
    "pypdf==3.15.1"
    "img2pdf==0.4.4"
    "pdfkit==1.0.0"
    "pytesseract==0.3.10"
    "free-proxy==1.0.4"
    "proxy-checker==0.6"
    "pystealth==0.0.12"
    "better-proxy==0.4.0"
    "streamlit==1.24.1"
    "docker==6.1.3"
    "python-slugify==8.0.1"
    "tldextract==3.4.4"
    "pytest-asyncio==0.21.1"
)

# MLX packages for Apple Silicon
MLX_PACKAGES=(
    "mlx==0.0.10" 
    "mlx-lm==0.0.3"
)

# Function to display progress animation
show_progress() {
    local message="$1"
    local duration="$2"
    local interval=0.1
    local iterations=$(echo "$duration / $interval" | bc)
    
    for ((i=0; i<iterations; i++)); do
        local animation_frame="${LLAMA_ANIMATION[$((i % ${#LLAMA_ANIMATION[@]}))]}"
        echo -ne "\r${animation_frame} ${message} "
        sleep $interval
    done
    echo -e "\r${GREEN}✓${RESET} ${message} ${GREEN}[DONE]${RESET}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Display logo and introduction
display_intro() {
    clear
    echo -e "$LOGO"
    echo -e "${YELLOW}${BOLD}Setting up ElysianLens, please wait...${RESET}\n"
}

# Check system requirements
check_system_requirements() {
    echo -e "\n${BLUE}${BOLD}[1/7] Checking system requirements...${RESET}"
    
    # Check macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        echo -e "${RED}Error: This script is designed for macOS.${RESET}"
        exit 1
    fi
    echo -e "${GREEN}✓${RESET} macOS detected"
    
    # Check Apple Silicon for MLX optimization
    if [[ "$(uname -m)" == "arm64" ]]; then
        APPLE_SILICON=true
        echo -e "${GREEN}✓${RESET} Apple Silicon detected - MLX acceleration will be enabled"
        
        # Detect specific chip if possible
        if command_exists "sysctl"; then
            CHIP=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Apple Silicon")
            echo -e "${GREEN}✓${RESET} $CHIP detected"
        fi
    else
        APPLE_SILICON=false
        echo -e "${YELLOW}⚠${RESET} Intel Mac detected - MLX acceleration will not be available"
    fi
    
    # Check required tools
    for tool in "${REQUIRED_TOOLS[@]}"; do
        if ! command_exists "$tool"; then
            echo -e "${YELLOW}⚠${RESET} $tool is not installed"
            
            # Handle Homebrew installation if missing
            if [[ "$tool" == "brew" ]]; then
                echo -e "${BLUE}i${RESET} Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            elif [[ "$tool" == "python3" || "$tool" == "pip3" ]]; then
                echo -e "${YELLOW}⚠${RESET} Python 3 is required. Please install Python 3 and try again."
                exit 1
            else
                echo -e "${BLUE}i${RESET} Installing $tool using Homebrew..."
                brew install "$tool"
            fi
        else
            echo -e "${GREEN}✓${RESET} $tool is installed"
        fi
    done
    
    # Check Python version
    PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
    if [[ $(echo "$PYTHON_VERSION >= 3.9" | bc -l) -eq 1 ]]; then
        echo -e "${GREEN}✓${RESET} Python $PYTHON_VERSION detected"
    else
        echo -e "${RED}Error: Python 3.9+ is required (found $PYTHON_VERSION)${RESET}"
        exit 1
    fi
    
    # Check system memory
    if command_exists "sysctl"; then
        MEM_SIZE=$(sysctl -n hw.memsize 2>/dev/null || echo 0)
        MEM_GB=$((MEM_SIZE / 1024 / 1024 / 1024))
        if [[ $MEM_GB -lt 8 ]]; then
            echo -e "${YELLOW}⚠${RESET} Low memory detected ($MEM_GB GB). Some features may be limited."
        else
            echo -e "${GREEN}✓${RESET} Sufficient memory detected ($MEM_GB GB)"
        fi
    fi
    
    show_progress "System requirements check completed" 1
}

# Create necessary directories
create_directories() {
    echo -e "\n${BLUE}${BOLD}[2/7] Creating directory structure...${RESET}"
    
    # Create main project directory
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR"
    
    # Initialize git repository
    initialize_git_repository
    
    # Create subdirectories
    for dir in "${DIRECTORIES[@]}"; do
        mkdir -p "$dir"
        echo -e "${GREEN}✓${RESET} Created directory: $dir"
    done
}

# Set up a professional Git repository
initialize_git_repository() {
    if [ ! -d ".git" ]; then
        echo -e "${BLUE}i${RESET} Initializing Git repository..."
        git init -q
        
        # Create .gitignore
        cat > .gitignore << EOL
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
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
*.egg-info/
.installed.cfg
*.egg

# Virtual Environment
env/
venv/
ENV/
env.bak/
venv.bak/

# IDE files
.idea/
.vscode/
*.swp
*.swo

# OS specific
.DS_Store
.AppleDouble
.LSOverride
Thumbs.db

# ElysianLens specific
configs/api_keys.json
logs/*.log
data/raw/*
!data/raw/.gitkeep
data/processed/*
!data/processed/.gitkeep
reports/*
!reports/.gitkeep
EOL
        echo -e "${GREEN}✓${RESET} Created .gitignore"
        
        # Create README.md
        cat > README.md << EOL
# ElysianLens

![ElysianLens Logo](assets/images/elysian_lens_logo.png)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.9+](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org/downloads/)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

## The Elegant Web Data Harvesting & Analysis Platform

ElysianLens is a sophisticated data extraction and analysis platform designed for ethical web scraping, data visualization, and insightful reporting.

## Features

- **Advanced Web Scraping**: Extract data from websites with sophisticated bypassing of anti-scraping mechanisms
- **Ethical Crawling**: Respect robots.txt, set appropriate delays, and follow best practices
- **Intelligent Data Extraction**: ML-powered content classification and extraction
- **Beautiful Visualizations**: Generate insightful charts and graphs from collected data
- **Comprehensive Reporting**: Export findings to PDF, CSV, JSON, and more
- **Interactive Mode**: User-friendly CLI for ad-hoc scraping tasks
- **Scheduler**: Automate recurring scraping jobs
- **Proxy Management**: Rotate through proxies to avoid IP bans

## Installation

\`\`\`bash
# Clone the repository
git clone https://github.com/yourusername/elysian-lens.git
cd elysian-lens

# Run the installer
./main.sh
\`\`\`

## Usage

After installation, use the following commands:

\`\`\`bash
# Launch the interactive mode
elysian_lens interactive

# Scrape a website
elysian_lens scrape https://example.com

# Generate a report
elysian_lens report 1 --format pdf

# Display version information
elysian_lens version

# Get help
elysian_lens --help
\`\`\`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
EOL
        echo -e "${GREEN}✓${RESET} Created README.md"
        
        # Create LICENSE file
        cat > LICENSE << EOL
MIT License

Copyright (c) $(date +%Y)

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
EOL
        echo -e "${GREEN}✓${RESET} Created LICENSE file"
        
        # Set up GitHub Actions CI/CD
        setup_github_actions
        
        # Set up Docker containerization
        setup_docker_files
        
        # Create contribution guidelines and code of conduct
        create_community_docs
        
        # Create initial commit
        git add .gitignore README.md LICENSE .github Dockerfile docker-compose.yml .dockerignore CONTRIBUTING.md CODE_OF_CONDUCT.md
        git config --local user.name "ElysianLens Developer"
        git config --local user.email "dev@elysianlens.dev"
        git commit -q -m "Initial commit: Project structure and documentation"
        echo -e "${GREEN}✓${RESET} Created initial commit"
    else
        echo -e "${BLUE}i${RESET} Git repository already initialized"
    fi
}

# Create community documentation files
create_community_docs() {
    echo -e "${BLUE}i${RESET} Creating community documentation..."
    
    # Create CONTRIBUTING.md
    cat > CONTRIBUTING.md << EOL
# Contributing to ElysianLens

First off, thank you for considering contributing to ElysianLens!

## Code of Conduct

By participating in this project, you are expected to uphold our [Code of Conduct](CODE_OF_CONDUCT.md).

## How Can I Contribute?

### Reporting Bugs
### Suggesting Enhancements
### Pull Requests

## Styleguides

### Git Commit Messages
### Python Styleguide
EOL

    # Create CODE_OF_CONDUCT.md
    cat > CODE_OF_CONDUCT.md << EOL
# Contributor Covenant Code of Conduct

## Our Pledge

We as members, contributors, and leaders pledge to make participation in our
community a harassment-free experience for everyone.

## Our Standards
## Enforcement Responsibilities
## Scope
## Enforcement

## Attribution

This Code of Conduct is adapted from the [Contributor Covenant](https://www.contributor-covenant.org),
version 2.0.
EOL

    echo -e "${GREEN}✓${RESET} Created community documentation"
}

# Set up Docker containerization files
setup_docker_files() {
    echo -e "${BLUE}i${RESET} Creating Docker configuration..."
    
    # Create Dockerfile
    cat > Dockerfile << EOL
FROM python:3.11-slim

WORKDIR /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \\
    PYTHONUNBUFFERED=1 \\
    PIP_NO_CACHE_DIR=off \\
    PIP_DISABLE_PIP_VERSION_CHECK=on

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \\
    build-essential \\
    curl \\
    git \\
    wkhtmltopdf \\
    tesseract-ocr \\
    && apt-get clean \\
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . .

# Create necessary directories
RUN mkdir -p /app/data/raw /app/data/processed /app/logs /app/reports

# Set permissions
RUN chmod +x /app/src/cli.py

# Create a symlink for the CLI
RUN ln -s /app/src/cli.py /usr/local/bin/elysian_lens

# Set the entrypoint
ENTRYPOINT ["elysian_lens"]
CMD ["--help"]
EOL

    # Create docker-compose.yml
    cat > docker-compose.yml << EOL
version: '3.8'

services:
  app:
    build: .
    volumes:
      - ./data:/app/data
      - ./logs:/app/logs
      - ./reports:/app/reports
      - ./configs:/app/configs
    environment:
      - PYTHONUNBUFFERED=1
    command: interactive
    stdin_open: true
    tty: true

  scraper:
    build: .
    volumes:
      - ./data:/app/data
      - ./logs:/app/logs
      - ./reports:/app/reports
      - ./configs:/app/configs
    environment:
      - PYTHONUNBUFFERED=1
    command: scrape https://example.com
    profiles:
      - scrape

  scheduler:
    build: .
    volumes:
      - ./data:/app/data
      - ./logs:/app/logs
      - ./reports:/app/reports
      - ./configs:/app/configs
    environment:
      - PYTHONUNBUFFERED=1
    command: scheduler
    profiles:
      - scheduler
EOL

    # Create .dockerignore
    cat > .dockerignore << EOL
# Git
.git
.github
.gitignore

# Docker
Dockerfile
docker-compose.yml
.dockerignore

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
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
*.egg-info/
.installed.cfg
*.egg

# Directories with runtime data
data/raw/*
data/processed/*
logs/*
reports/*

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db
EOL

    echo -e "${GREEN}✓${RESET} Created Docker configuration files"
    
    # Add Docker usage instructions to README
    cat >> README.md << EOL

## Docker Usage

ElysianLens can also be run using Docker:

\`\`\`bash
# Build and run the interactive mode
docker-compose up app

# Run a scraping job
docker-compose run --rm scraper scrape https://example.com

# Run the scheduler
docker-compose run --rm scheduler scheduler
\`\`\`
EOL
}

# Set up GitHub Actions CI/CD workflows
setup_github_actions() {
    echo -e "${BLUE}i${RESET} Setting up GitHub Actions CI/CD..."
    
    # Create GitHub Actions directory
    mkdir -p .github/workflows
    
    # Create CI workflow for testing
    cat > .github/workflows/tests.yml << EOL
name: Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.9, 3.10, 3.11]

    steps:
    - uses: actions/checkout@v3
    - name: Set up Python \${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: \${{ matrix.python-version }}
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
        pip install pytest pytest-cov black flake8
    - name: Lint with flake8
      run: |
        # stop the build if there are Python syntax errors or undefined names
        flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
        # exit-zero treats all errors as warnings
        flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
    - name: Check formatting with black
      run: |
        black --check .
    - name: Test with pytest
      run: |
        pytest --cov=src tests/
EOL

    # Create CD workflow for releases
    cat > .github/workflows/release.yml << EOL
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.10'
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install build twine
        if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
    - name: Build package
      run: |
        python -m build
    - name: Create Release
      id: create_release
      uses: actions/create-release@v1
      env:
        GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
      with:
        tag_name: \${{ github.ref }}
        release_name: Release \${{ github.ref }}
        draft: false
        prerelease: false
    - name: Upload Release Asset
      uses: actions/upload-release-asset@v1
      env:
        GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
      with:
        upload_url: \${{ steps.create_release.outputs.upload_url }}
        asset_path: ./dist/elysian_lens-*.whl
        asset_name: elysian_lens.whl
        asset_content_type: application/octet-stream
EOL

    # Create dependabot configuration
    cat > .github/dependabot.yml << EOL
version: 2
updates:
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    labels:
      - "dependencies"
      - "automerge"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
    labels:
      - "ci-cd"
      - "automerge"
EOL

    echo -e "${GREEN}✓${RESET} Created GitHub Actions workflows"
}

# Function to create git commits at appropriate stages in the installation
create_git_commit() {
    local message="$1"
    git add .
    git commit -q -m "$message"
    echo -e "${GREEN}✓${RESET} Created commit: $message"
}

# Set up Python environment
setup_python_environment() {
    echo -e "\n${BLUE}${BOLD}[3/7] Setting up Python environment...${RESET}"
    
    # Create virtual environment
    if [[ -d "$INSTALL_DIR/venv" ]]; then
        echo -e "${YELLOW}⚠${RESET} Existing virtual environment found. Recreating..."
        rm -rf "$INSTALL_DIR/venv"
    fi
    
    echo -e "${BLUE}i${RESET} Creating virtual environment..."
    python3 -m venv "$INSTALL_DIR/venv"
    
    # Activate virtual environment
    source "$INSTALL_DIR/venv/bin/activate"
    
    # Upgrade pip
    echo -e "${BLUE}i${RESET} Upgrading pip..."
    pip install --upgrade pip
    
    # Install Python packages
    echo -e "${BLUE}i${RESET} Installing Python packages..."
    for package in "${PYTHON_PACKAGES[@]}"; do
        echo -e "${BLUE}i${RESET} Installing $package..."
        pip install "$package"
    done
    
    # Install MLX packages for Apple Silicon
    if [[ "$APPLE_SILICON" == true ]]; then
        echo -e "${BLUE}i${RESET} Installing MLX packages for Apple Silicon..."
        for package in "${MLX_PACKAGES[@]}"; do
            pip install "$package"
        done
    fi
    
    # Install browser automation tools
    echo -e "${BLUE}i${RESET} Installing Playwright browsers..."
    python -m playwright install chromium firefox webkit
    
    # Install testing tools
    echo -e "${BLUE}i${RESET} Installing testing tools..."
    pip install pytest pytest-asyncio pytest-cov pytest-mock pytest-html
    
    show_progress "Python environment setup completed" 1
}

# Generate configuration files
generate_config_files() {
    echo -e "\n${BLUE}${BOLD}[4/7] Generating configuration files...${RESET}"
    
    # Generate .env file if it doesn't exist
    if [[ ! -f "$ENV_FILE" ]]; then
        cat > "$ENV_FILE" << EOF
# ElysianLens Configuration
ELYSIAN_ENV=development
LOG_LEVEL=info

# API Settings
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
GROK_API_KEY=

# Proxy Settings
USE_PROXIES=false
PROXY_ROTATION_INTERVAL=300
PROXY_TEST_TIMEOUT=10

# Scraping Settings
DEFAULT_USER_AGENT="Mozilla/5.0 (Macintosh; Apple Silicon Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36"
STEALTH_MODE=true
REQUEST_TIMEOUT=30
MAX_RETRIES=3
DEFAULT_CRAWL_DELAY=2

# Storage Settings
VECTOR_DB_PATH=$DATA_DIR/vectors
SCRAPE_DB_PATH=$DATA_DIR/scraped/scrapedata.db

# MLX Settings
MLX_USE_GPU=true
MLX_MODEL_PATH=$MODELS_DIR
EOF
        echo -e "${GREEN}✓${RESET} Created .env file"
    else
        echo -e "${GREEN}✓${RESET} Using existing .env file"
    fi
    
    # Create empty proxies.json if it doesn't exist
    if [[ ! -f "$PROXY_FILE" ]]; then
        cat > "$PROXY_FILE" << EOF
{
  "http": [],
  "https": [],
  "socks4": [],
  "socks5": []
}
EOF
        echo -e "${GREEN}✓${RESET} Created proxies.json file"
    else
        echo -e "${GREEN}✓${RESET} Using existing proxies.json file"
    fi
    
    # Create empty API keys file if it doesn't exist
    if [[ ! -f "$API_KEYS_FILE" ]]; then
        cat > "$API_KEYS_FILE" << EOF
{
  "openai": "",
  "anthropic": "",
  "grok": ""
}
EOF
        echo -e "${GREEN}✓${RESET} Created api_keys.json file"
    else
        echo -e "${GREEN}✓${RESET} Using existing api_keys.json file"
    fi
    
    show_progress "Configuration files generated" 1
}

# Configure API keys
configure_api_keys() {
    echo -e "\n${BLUE}${BOLD}[5/7] Configuring API keys...${RESET}"
    
    echo -e "${YELLOW}Would you like to configure API keys now? (y/n)${RESET}"
    read -r setup_keys
    
    if [[ "$setup_keys" == "y" || "$setup_keys" == "Y" ]]; then
        echo -e "${BLUE}i${RESET} Enter your OpenAI API key (leave empty to skip):"
        read -r openai_key
        
        echo -e "${BLUE}i${RESET} Enter your Anthropic API key (leave empty to skip):"
        read -r anthropic_key
        
        echo -e "${BLUE}i${RESET} Enter your Grok API key (leave empty to skip):"
        read -r grok_key
        
        # Update API keys file
        if [[ -n "$openai_key" ]]; then
            sed -i '' "s/\"openai\": \".*\"/\"openai\": \"$openai_key\"/" "$API_KEYS_FILE"
            sed -i '' "s/OPENAI_API_KEY=.*/OPENAI_API_KEY=$openai_key/" "$ENV_FILE"
            echo -e "${GREEN}✓${RESET} OpenAI API key configured"
        fi
        
        if [[ -n "$anthropic_key" ]]; then
            sed -i '' "s/\"anthropic\": \".*\"/\"anthropic\": \"$anthropic_key\"/" "$API_KEYS_FILE"
            sed -i '' "s/ANTHROPIC_API_KEY=.*/ANTHROPIC_API_KEY=$anthropic_key/" "$ENV_FILE"
            echo -e "${GREEN}✓${RESET} Anthropic API key configured"
        fi
        
        if [[ -n "$grok_key" ]]; then
            sed -i '' "s/\"grok\": \".*\"/\"grok\": \"$grok_key\"/" "$API_KEYS_FILE"
            sed -i '' "s/GROK_API_KEY=.*/GROK_API_KEY=$grok_key/" "$ENV_FILE"
            echo -e "${GREEN}✓${RESET} Grok API key configured"
        fi
    else
        echo -e "${BLUE}i${RESET} Skipping API key configuration"
    fi
    
    show_progress "API keys configuration completed" 1
}

# Generate main Python application file
generate_application_files() {
    echo -e "\n${BLUE}${BOLD}[6/7] Generating application files...${RESET}"
    
    # Create main Python file
    cat > "$INSTALL_DIR/elysian_lens.py" << 'EOF'
#!/usr/bin/env python3
"""
ElysianLens: An Elegant Web Data Harvesting & Analysis Platform
"""

import os
import sys
import json
import asyncio
import logging
import time
from typing import List, Dict, Any, Optional, Union
from pathlib import Path
from datetime import datetime
import random
import socket
import traceback
import argparse
import urllib.parse
from functools import wraps
from contextlib import contextmanager
import re
import signal
import hashlib
import base64
import tempfile
import shutil
import atexit
import sqlite3
import concurrent.futures
import threading
import queue
import uuid

# Check Python version
if sys.version_info < (3, 9):
    print("Error: ElysianLens requires Python 3.9 or higher")
    sys.exit(1)

try:
    # Third-party imports
    import dotenv
    from rich.console import Console
    from rich.panel import Panel
    from rich.progress import Progress, SpinnerColumn, TextColumn, BarColumn, TimeElapsedColumn
    from rich.prompt import Prompt, Confirm
    from rich.table import Table
    from rich.layout import Layout
    from rich.live import Live
    from rich.syntax import Syntax
    from rich.markdown import Markdown
    from rich.box import ROUNDED, DOUBLE, HEAVY
    import typer
    import requests
    from bs4 import BeautifulSoup
    import aiohttp
    from playwright.async_api import async_playwright, Browser, Page, BrowserContext
    import pandas as pd
    import numpy as np
    from PIL import Image
    import sqlite_utils
    import pdfkit
    import markdownify
    import tldextract
    from slugify import slugify
    
    # Conditional import for MLX on Apple Silicon
    try:
        if sys.platform == "darwin" and os.uname().machine == "arm64":
            import mlx.core as mx
            import mlx.nn as nn
            HAS_MLX = True
        else:
            HAS_MLX = False
    except ImportError:
        HAS_MLX = False
    
    # Try to import API clients
    try:
        import openai
        import anthropic
        HAS_API_CLIENTS = True
    except ImportError:
        HAS_API_CLIENTS = False
        
except ImportError as e:
    print(f"Error: Missing required Python package: {e}")
    print("Please run the setup script again to install dependencies.")
    sys.exit(1)

# Setup basic configuration
APP_NAME = "ElysianLens"
APP_VERSION = "1.0.0"
APP_DESCRIPTION = "An Elegant Web Data Harvesting & Analysis Platform"

# Load environment variables
config_dir = os.path.expanduser("~/.elysian_lens")
env_path = os.path.join(config_dir, ".env")
dotenv.load_dotenv(env_path)

# Configure logging
log_dir = os.path.join(config_dir, "logs")
os.makedirs(log_dir, exist_ok=True)
log_file = os.path.join(log_dir, f"{APP_NAME.lower()}_{datetime.now().strftime('%Y%m%d')}.log")

logging.basicConfig(
    level=getattr(logging, os.getenv("LOG_LEVEL", "INFO").upper()),
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    handlers=[
        logging.FileHandler(log_file),
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger(APP_NAME)

# Rich console setup
console = Console()

# Color scheme
COLORS = {
    "primary": "deep_sky_blue1",
    "secondary": "slate_blue3",
    "accent": "hot_pink",
    "success": "green",
    "warning": "yellow",
    "error": "red",
    "info": "blue",
    "muted": "grey70",
    "title": "bold deep_sky_blue1",
    "subtitle": "slate_blue3",
    "heading": "bold deep_sky_blue1",
    "text": "white",
    "llama": "bright_magenta",
}

# ASCII art for the llama logo
LLAMA_ASCII_ART = """
                  .,,'
             .,''''''',.
          .,'',,,,,,,,,,',.
        .'',,,,,,,,,,,,,,,,',.
      .',,,,,,,,,,,,,,,,,,,,,'.
     .',,,,,,,,,,,,,,,,,,,,,,,,'.
    .',,,,,,,,,,,,,,,,,,,,,,,,,,'.
   .',,,,,,,,,,,,,,,,,,,,,,,,,,,,,'.
   .',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,'.
  .',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.
  .',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,'.
 .',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.
 .',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,'.
 .',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.
',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.
',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,'.
',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,'.
',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.
',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.
',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.
.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.
 ',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.
  ',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,'.
   .',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,'.
    .,,ElysianLens,,,,,,,,,,,,,,,,,,'.
     .',,,,,,,,,,,,,,,,,,,,,,,,,,'.
       .',,,,,,,,,,,,,,,,,,,,,,'.
         .',,,,,,,,,,,,,,,,,'.
           ..',,,,,,,,,,'.
               ..'''..
"""

class LlamaSpinner:
    """Custom spinner animation with Llama theme"""
    
    def __init__(self):
        self.frames = [
            "🦙 ", 
            " 🦙", 
            "  🦙", 
            "   🦙", 
            "    🦙", 
            "     🦙", 
            "      🦙", 
            "     🦙 ", 
            "    🦙  ", 
            "   🦙   ", 
            "  🦙    ", 
            " 🦙     "
        ]
        self.current_frame = 0
    
    def get_frame(self):
        """Get the current frame of the spinner"""
        frame = self.frames[self.current_frame]
        self.current_frame = (self.current_frame + 1) % len(self.frames)
        return frame

class Configuration:
    """Configuration manager for ElysianLens"""
    
    def __init__(self):
        self.config_dir = os.path.expanduser("~/.elysian_lens")
        self.env_file = os.path.join(self.config_dir, ".env")
        self.api_keys_file = os.path.join(self.config_dir, "api_keys.json")
        self.proxies_file = os.path.join(self.config_dir, "proxies.json")
        self.data_dir = os.path.join(self.config_dir, "data")
        self.models_dir = os.path.join(self.config_dir, "models")
        
        # Load configurations
        self.env = self._load_env()
        self.api_keys = self._load_json(self.api_keys_file)
        self.proxies = self._load_json(self.proxies_file)
        
        # Initialize API clients if keys are available
        self._init_api_clients()
    
    def _load_env(self):
        """Load environment variables from .env file"""
        if not os.path.exists(self.env_file):
            logger.warning(f".env file not found at {self.env_file}")
            return {}
            
        return dotenv.dotenv_values(self.env_file)
    
    def _load_json(self, filepath):
        """Load JSON configuration file"""
        if not os.path.exists(filepath):
            logger.warning(f"Config file not found at {filepath}")
            return {}
            
        try:
            with open(filepath, 'r') as f:
                return json.load(f)
        except json.JSONDecodeError:
            logger.error(f"Error parsing JSON file: {filepath}")
            return {}
    
    def _init_api_clients(self):
        """Initialize API clients with available keys"""
        if not HAS_API_CLIENTS:
            logger.warning("API clients not available - missing libraries")
            return
            
        # Setup OpenAI client
        openai_key = self.api_keys.get("openai") or os.getenv("OPENAI_API_KEY")
        if openai_key:
            openai.api_key = openai_key
            logger.info("OpenAI client initialized")
        
        # Setup Anthropic client
        anthropic_key = self.api_keys.get("anthropic") or os.getenv("ANTHROPIC_API_KEY")
        if anthropic_key:
            self.anthropic_client = anthropic.Anthropic(api_key=anthropic_key)
            logger.info("Anthropic client initialized")
    
    def get(self, key, default=None):
        """Get a configuration value from environment variables"""
        return os.getenv(key) or self.env.get(key) or default
    
    def save_proxies(self, proxies):
        """Save proxies to the proxies file"""
        with open(self.proxies_file, 'w') as f:
            json.dump(proxies, f, indent=2)
        self.proxies = proxies

class ProxyManager:
    """Manages and rotates proxies for web scraping"""
    
    def __init__(self, config):
        self.config = config
        self.proxies = config.proxies
        self.current_index = 0
        self.last_rotation = time.time()
        self.rotation_interval = int(config.get("PROXY_ROTATION_INTERVAL", 300))
        self.test_timeout = int(config.get("PROXY_TEST_TIMEOUT", 10))
        self.use_proxies = config.get("USE_PROXIES", "false").lower() == "true"
    
    async def fetch_free_proxies(self):
        """Fetch free proxies from various sources"""
        if not self.use_proxies:
            return
            
        logger.info("Fetching free proxies...")
        
        with console.status("[bold blue]Fetching free proxies...", spinner="dots"):
            try:
                # Proxy sources - simplified for the script
                sources = [
                    "https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/http.txt",
                    "https://raw.githubusercontent.com/ShiftyTR/Proxy-List/master/https.txt",
                    "https://raw.githubusercontent.com/monosans/proxy-list/main/proxies/http.txt",
                ]
                
                new_proxies = {
                    "http": [],
                    "https": [],
                    "socks4": [],
                    "socks5": []
                }
                
                async with aiohttp.ClientSession() as session:
                    for source in sources:
                        try:
                            async with session.get(source, timeout=10) as response:
                                if response.status == 200:
                                    text = await response.text()
                                    proxies = text.strip().split("\n")
                                    # Simple filtering for structure
                                    for proxy in proxies:
                                        proxy = proxy.strip()
                                        if proxy and ":" in proxy:
                                            # Classify proxy type - simplified
                                            if source.endswith("http.txt"):
                                                new_proxies["http"].append(f"http://{proxy}")
                                            elif source.endswith("https.txt"):
                                                new_proxies["https"].append(f"https://{proxy}")
                                            elif source.endswith("socks4.txt"):
                                                new_proxies["socks4"].append(f"socks4://{proxy}")
                                            elif source.endswith("socks5.txt"):
                                                new_proxies["socks5"].append(f"socks5://{proxy}")
                        except Exception as e:
                            logger.error(f"Error fetching proxies from {source}: {e}")
                
                # Merge with existing proxies
                for proxy_type, proxy_list in new_proxies.items():
                    existing = set(self.proxies.get(proxy_type, []))
                    existing.update(proxy_list)
                    self.proxies[proxy_type] = list(existing)
                
                # Save updated proxies
                self.config.save_proxies(self.proxies)
                
                logger.info(f"Fetched proxies: HTTP: {len(new_proxies['http'])}, HTTPS: {len(new_proxies['https'])}, "
                           f"SOCKS4: {len(new_proxies['socks4'])}, SOCKS5: {len(new_proxies['socks5'])}")
            except Exception as e:
                logger.error(f"Failed to fetch free proxies: {e}")
    
    async def test_proxy(self, proxy_url, test_url="https://httpbin.org/ip"):
        """Test if a proxy is working"""
        try:
            proxy_type = proxy_url.split("://")[0] if "://" in proxy_url else "http"
            proxies = {proxy_type: proxy_url}
            
            async with aiohttp.ClientSession() as session:
                async with session.get(
                    test_url,
                    proxy=proxy_url,
                    timeout=self.test_timeout
                ) as response:
                    if response.status == 200:
                        return True
            return False
        except Exception:
            return False
    
    async def verify_proxies(self):
        """Verify and filter working proxies"""
        if not self.use_proxies or not self.proxies:
            return
            
        logger.info("Verifying proxies...")
        working_proxies = {
            "http": [],
            "https": [],
            "socks4": [],
            "socks5": []
        }
        
        with Progress(
            SpinnerColumn(),
            TextColumn("[bold blue]Testing proxies..."),
            BarColumn(),
            TextColumn("[progress.percentage]{task.percentage:>3.0f}%"),
            TimeElapsedColumn(),
            console=console
        ) as progress:
            for proxy_type, proxy_list in self.proxies.items():
                if not proxy_list:
                    continue
                    
                task = progress.add_task(f"[cyan]Testing {proxy_type} proxies", total=len(proxy_list))
                
                for proxy in proxy_list:
                    is_working = await self.test_proxy(proxy)
                    if is_working:
                        working_proxies[proxy_type].append(proxy)
                    progress.update(task, advance=1)
        
        # Update proxies with working ones
        self.proxies = working_proxies
        self.config.save_proxies(working_proxies)
        
        total_working = sum(len(proxies) for proxies in working_proxies.values())
        logger.info(f"Verified {total_working} working proxies")
    
    def get_next_proxy(self):
        """Get the next proxy in rotation"""
        if not self.use_proxies:
            return None
            
        # Check if it's time for rotation
        current_time = time.time()
        if current_time - self.last_rotation >= self.rotation_interval:
            self.last_rotation = current_time
            self.current_index = 0
        
        # Flatten all proxies into a single list
        all_proxies = []
        for proxy_list in self.proxies.values():
            all_proxies.extend(proxy_list)
        
        if not all_proxies:
            return None
        
        # Get next proxy
        proxy = all_proxies[self.current_index % len(all_proxies)]
        self.current_index += 1
        
        return proxy

class BrowserTools:
    """Handles browser automation and stealth techniques"""
    
    def __init__(self, config, proxy_manager=None):
        self.config = config
        self.proxy_manager = proxy_manager
        self.browser = None
        self.context = None
        self.stealth_mode = config.get("STEALTH_MODE", "true").lower() == "true"
        self.default_user_agent = config.get("DEFAULT_USER_AGENT")
        
        # User agents rotation
        self.user_agents = [
            "Mozilla/5.0 (Macintosh; Apple Silicon Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36",
            "Mozilla/5.0 (Macintosh; Apple M3 Mac OS X 14_0_0) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15",
            "Mozilla/5.0 (Macintosh; Apple Silicon Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36 Edg/118.0.2088.76",
            "Mozilla/5.0 (Macintosh; Apple Silicon Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36 OPR/105.0.0.0",
            "Mozilla/5.0 (Macintosh; Apple Silicon Mac OS X) Gecko Firefox/121.0"
        ]
    
    async def initialize(self):
        """Initialize browser and context"""
        playwright = await async_playwright().start()
        
        # Setup browser launch options
        browser_args = []
        if self.stealth_mode:
            browser_args.extend([
                "--disable-blink-features=AutomationControlled",
                "--disable-features=IsolateOrigins,site-per-process",
                "--disable-site-isolation-trials",
            ])
        
        # Setup proxy if available
        proxy_options = {}
        if self.proxy_manager and self.proxy_manager.use_proxies:
            proxy = self.proxy_manager.get_next_proxy()
            if proxy:
                proxy_options = {"server": proxy}
        
        # Launch browser
        self.browser = await playwright.chromium.launch(
            headless=True,
            args=browser_args,
            proxy=proxy_options if proxy_options else None
        )
        
        # Create browser context with stealth options
        user_agent = random.choice(self.user_agents)
        
        self.context = await self.browser.new_context(
            user_agent=user_agent,
            viewport={"width": 1920, "height": 1080},
            device_scale_factor=2.0,
            locale="en-US",
            timezone_id="America/New_York",
            color_scheme="light"
        )
        
        # Apply additional stealth techniques
        if self.stealth_mode:
            await self._apply_stealth_techniques()
        
        return self.context
    
    async def _apply_stealth_techniques(self):
        """Apply additional stealth techniques to avoid detection"""
        if not self.context:
            raise ValueError("Browser context not initialized")
        
        # Evaluate stealth script in context
        await self.context.add_init_script("""
        () => {
            // Overwrite navigator properties
            Object.defineProperty(navigator, 'webdriver', {
                get: () => false
            });
            
            // Overwrite permissions
            const originalQuery = window.navigator.permissions.query;
            window.navigator.permissions.query = (parameters) => (
                parameters.name === 'notifications' ?
                Promise.resolve({state: Notification.permission}) :
                originalQuery(parameters)
            );
            
            // Add fake plugins
            Object.defineProperty(navigator, 'plugins', {
                get: () => {
                    return [
                        { name: 'PDF Viewer', filename: 'internal-pdf-viewer', description: 'Portable Document Format' },
                        { name: 'Chrome PDF Viewer', filename: 'internal-pdf-viewer', description: 'Portable Document Format' },
                        { name: 'Chromium PDF Viewer', filename: 'internal-pdf-viewer', description: 'Portable Document Format' },
                        { name: 'Microsoft Edge PDF Viewer', filename: 'internal-pdf-viewer', description: 'Portable Document Format' },
                        { name: 'WebKit built-in PDF', filename: 'internal-pdf-viewer', description: 'Portable Document Format' }
                    ];
                }
            });
            
            // Add random canvas fingerprint noise
            const originalToDataURL = HTMLCanvasElement.prototype.toDataURL;
            HTMLCanvasElement.prototype.toDataURL = function(type) {
                if (type === 'image/png' && this.width === 16 && this.height === 16) {
                    return originalToDataURL.apply(this, arguments);
                }
                
                const context = this.getContext('2d');
                const data = context.getImageData(0, 0, this.width, this.height);
                
                // Add minor noise to canvas data
                for (let i = 0; i < data.data.length; i += 4) {
                    const noise = Math.floor(Math.random() * 3) - 1;
                    data.data[i] = Math.max(0, Math.min(255, data.data[i] + noise));
                    data.data[i+1] = Math.max(0, Math.min(255, data.data[i+1] + noise));
                    data.data[i+2] = Math.max(0, Math.min(255, data.data[i+2] + noise));
                }
                
                context.putImageData(data, 0, 0);
                return originalToDataURL.apply(this, arguments);
            };
        }
        """)
    
    async def new_page(self):
        """Create a new page with stealth setup"""
        if not self.context:
            await self.initialize()
        
        page = await self.context.new_page()
        
        # Add random delay between actions
        await page.route("**/*", self._add_random_delay)
        
        return page
    
    async def _add_random_delay(self, route, request):
        """Add random delay to requests for more human-like behavior"""
        delay = random.uniform(100, 500)  # 100-500ms
        await asyncio.sleep(delay / 1000)  # Convert to seconds
        await route.continue_()
    
    async def take_full_page_screenshot(self, page, output_path):
        """Take a full page screenshot"""
        await page.screenshot(path=output_path, full_page=True)
        return output_path
    
    async def close(self):
        """Close browser and clean up resources"""
        if self.browser:
            await self.browser.close()
            self.browser = None
            self.context = None

class Scraper:
    """Main scraper class with advanced features"""
    
    def __init__(self, config, proxy_manager=None, browser_tools=None):
        self.config = config
        self.proxy_manager = proxy_manager
        self.browser_tools = browser_tools or BrowserTools(config, proxy_manager)
        self.max_retries = int(config.get("MAX_RETRIES", 3))
        self.request_timeout = int(config.get("REQUEST_TIMEOUT", 30))
        self.crawl_delay = float(config.get("DEFAULT_CRAWL_DELAY", 2))
        self.db_path = config.get("SCRAPE_DB_PATH", os.path.join(config.data_dir, "scraped/scrapedata.db"))
        
        # Initialize database
        self._init_database()
    
    def _init_database(self):
        """Initialize SQLite database for storing scraped data"""
        db_dir = os.path.dirname(self.db_path)
        os.makedirs(db_dir, exist_ok=True)
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Create necessary tables
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS scrape_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            url TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            completed BOOLEAN NOT NULL DEFAULT 0,
            pages_scraped INTEGER NOT NULL DEFAULT 0,
            status TEXT NOT NULL
        )
        ''')
        
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS pages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id INTEGER NOT NULL,
            url TEXT NOT NULL,
            title TEXT,
            content_hash TEXT NOT NULL,
            status_code INTEGER,
            content_type TEXT,
            timestamp TEXT NOT NULL,
            screenshot_path TEXT,
            FOREIGN KEY (session_id) REFERENCES scrape_sessions (id)
        )
        ''')
        
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS page_content (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            page_id INTEGER NOT NULL,
            content_type TEXT NOT NULL,
            content TEXT NOT NULL,
            metadata TEXT,
            FOREIGN KEY (page_id) REFERENCES pages (id)
        )
        ''')
        
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS links (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            source_page_id INTEGER NOT NULL,
            target_url TEXT NOT NULL,
            link_text TEXT,
            is_internal BOOLEAN NOT NULL,
            FOREIGN KEY (source_page_id) REFERENCES pages (id)
        )
        ''')
        
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            page_id INTEGER NOT NULL,
            url TEXT NOT NULL,
            alt_text TEXT,
            filename TEXT,
            width INTEGER,
            height INTEGER,
            FOREIGN KEY (page_id) REFERENCES pages (id)
        )
        ''')
        
        conn.commit()
        conn.close()
    
    async def scrape_url(self, url, depth=1, max_pages=10, take_screenshots=True, extract_pdf=True):
        """Scrape a URL with the specified depth"""
        logger.info(f"Starting scrape of {url} with depth {depth}")
        
        # Create a new session in the database
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO scrape_sessions (url, timestamp, status) VALUES (?, ?, ?)",
            (url, datetime.now().isoformat(), "in_progress")
        )
        session_id = cursor.lastrowid
        conn.commit()
        conn.close()
        
        try:
            # Initialize browser if needed
            if not self.browser_tools.browser:
                await self.browser_tools.initialize()
            
            # Crawl with BFS
            visited_urls = set()
            to_visit = [(url, 0)]  # (url, current_depth)
            pages_scraped = 0
            
            while to_visit and pages_scraped < max_pages:
                current_url, current_depth = to_visit.pop(0)
                
                if current_url in visited_urls:
                    continue
                
                visited_urls.add(current_url)
                
                # Scrape the page
                try:
                    page_data = await self._scrape_page(current_url, session_id, take_screenshots)
                    pages_scraped += 1
                    
                    # Extract PDF if requested and it's a PDF link
                    if extract_pdf and current_url.lower().endswith('.pdf'):
                        await self._extract_pdf(current_url, session_id)
                    
                    # Store links for further crawling
                    if current_depth < depth:
                        extracted_links = page_data.get("links", [])
                        for link in extracted_links:
                            if link["is_internal"] and link["target_url"] not in visited_urls:
                                to_visit.append((link["target_url"], current_depth + 1))
                    
                    # Random delay between requests to be polite
                    await asyncio.sleep(self.crawl_delay)
                    
                except Exception as e:
                    logger.error(f"Error scraping {current_url}: {e}")
            
            # Update session status
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            cursor.execute(
                "UPDATE scrape_sessions SET completed = 1, pages_scraped = ?, status = ? WHERE id = ?",
                (pages_scraped, "completed", session_id)
            )
            conn.commit()
            conn.close()
            
            logger.info(f"Scraping completed. Session ID: {session_id}, Pages scraped: {pages_scraped}")
            return {"session_id": session_id, "pages_scraped": pages_scraped}
            
        except Exception as e:
            logger.error(f"Error during scraping session: {e}")
            
            # Update session status to failed
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            cursor.execute(
                "UPDATE scrape_sessions SET status = ? WHERE id = ?",
                ("failed", session_id)
            )
            conn.commit()
            conn.close()
            
            raise
    
    async def _scrape_page(self, url, session_id, take_screenshots=True):
        """Scrape a single page and store the data"""
        logger.info(f"Scraping page: {url}")
        
        page = await self.browser_tools.new_page()
        
        try:
            # Navigate to the page
            response = await page.goto(url, timeout=self.request_timeout * 1000, wait_until="networkidle")
            
            if not response:
                logger.warning(f"No response from {url}")
                return None
            
            status_code = response.status
            content_type = response.headers.get("content-type", "")
            
            # Skip non-HTML responses except PDFs
            if "text/html" not in content_type and "application/pdf" not in content_type:
                logger.info(f"Skipping non-HTML content: {content_type} at {url}")
                return {"url": url, "status_code": status_code, "content_type": content_type}
            
            # Wait for the page to be fully loaded
            await page.wait_for_load_state("networkidle")
            
            # Extract page title
            title = await page.title()
            
            # Take a screenshot if requested
            screenshot_path = None
            if take_screenshots:
                screenshots_dir = os.path.join(self.config.data_dir, "exports/screenshots")
                os.makedirs(screenshots_dir, exist_ok=True)
                
                domain = urllib.parse.urlparse(url).netloc
                filename = f"{domain}_{hashlib.md5(url.encode()).hexdigest()[:10]}.png"
                screenshot_path = os.path.join(screenshots_dir, filename)
                
                await self.browser_tools.take_full_page_screenshot(page, screenshot_path)
            
            # Get page content
            html_content = await page.content()
            content_hash = hashlib.md5(html_content.encode()).hexdigest()
            
            # Extract text content
            text_content = await page.evaluate('''() => {
                return document.body.innerText;
            }''')
            
            # Extract links
            links = await page._extract_links(page, url)
            
            # Extract images
            images = await self._extract_images(page, url)
            
            # Store in database
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            # Store page info
            cursor.execute(
                """INSERT INTO pages (session_id, url, title, content_hash, status_code, 
                                     content_type, timestamp, screenshot_path) 
                   VALUES (?, ?, ?, ?, ?, ?, ?, ?)""",
                (session_id, url, title, content_hash, status_code, 
                 content_type, datetime.now().isoformat(), screenshot_path)
            )
            page_id = cursor.lastrowid
            
            # Store content
            cursor.execute(
                "INSERT INTO page_content (page_id, content_type, content, metadata) VALUES (?, ?, ?, ?)",
                (page_id, "html", html_content, json.dumps({"content_type": content_type}))
            )
            
            cursor.execute(
                "INSERT INTO page_content (page_id, content_type, content, metadata) VALUES (?, ?, ?, ?)",
                (page_id, "text", text_content, json.dumps({"extracted_from": "body"}))
            )
            
            # Store links
            base_domain = tldextract.extract(url).registered_domain
            for link in links:
                link_url = link["url"]
                link_text = link.get("text", "")
                
                # Determine if internal or external
                link_domain = tldextract.extract(link_url).registered_domain
                is_internal = link_domain == base_domain
                
                cursor.execute(
                    "INSERT INTO links (source_page_id, target_url, link_text, is_internal) VALUES (?, ?, ?, ?)",
                    (page_id, link_url, link_text, is_internal)
                )
            
            # Store images
            for image in images:
                cursor.execute(
                    """INSERT INTO images (page_id, url, alt_text, filename, width, height) 
                       VALUES (?, ?, ?, ?, ?, ?)""",
                    (page_id, image["url"], image.get("alt_text", ""), 
                     image.get("filename", ""), image.get("width", 0), image.get("height", 0))
                )
            
            conn.commit()
            conn.close()
            
            result = {
                "page_id": page_id,
                "url": url,
                "title": title,
                "status_code": status_code,
                "content_type": content_type,
                "links": links,
                "images": images
            }
            
            return result
            
        except Exception as e:
            logger.error(f"Error scraping page {url}: {e}")
            raise
            
        finally:
            await page.close()
    
    async def _extract_links(self, page, base_url):
        """Extract all links from a page"""
        links = await page.evaluate('''(baseUrl) => {
            const links = Array.from(document.querySelectorAll('a[href]'));
            return links.map(link => {
                let href = link.href;
                
                // Filter out javascript: and mailto: links
                if (href.startsWith('javascript:') || href.startsWith('mailto:') || href.startsWith('#')) {
                    return null;
                }
                
                return {
                    url: href,
                    text: link.textContent.trim(),
                    title: link.title || null,
                    rel: link.rel || null
                };
            }).filter(link => link !== null);
        }''', base_url)
        
        return links
    
    async def _extract_images(self, page, base_url):
        """Extract all images from a page"""
        images = await page.evaluate('''() => {
            const images = Array.from(document.querySelectorAll('img[src]'));
            return images.map(img => {
                return {
                    url: img.src,
                    alt_text: img.alt || null,
                    width: img.naturalWidth || img.width,
                    height: img.naturalHeight || img.height,
                    filename: img.src.split('/').pop().split('?')[0]
                };
            }).filter(img => img.url && img.url.startsWith('http'));
        }''')
        
        return images
    
    async def _extract_pdf(self, url, session_id):
        """Extract content from a PDF file"""
        try:
            # Download the PDF
            headers = {"User-Agent": random.choice(self.browser_tools.user_agents)}
            response = requests.get(url, headers=headers, timeout=self.request_timeout)
            
            if response.status_code != 200:
                logger.warning(f"Failed to download PDF from {url}: {response.status_code}")
                return
            
            # Save PDF to temporary file
            pdf_dir = os.path.join(self.config.data_dir, "exports/pdf")
            os.makedirs(pdf_dir, exist_ok=True)
            
            filename = f"{hashlib.md5(url.encode()).hexdigest()[:10]}.pdf"
            pdf_path = os.path.join(pdf_dir, filename)
            
            with open(pdf_path, 'wb') as f:
                f.write(response.content)
            
            # Extract text from PDF using pypdf
            try:
                import pypdf
                pdf_reader = pypdf.PdfReader(pdf_path)
                pdf_text = ""
                
                for page_num in range(len(pdf_reader.pages)):
                    page = pdf_reader.pages[page_num]
                    pdf_text += page.extract_text() + "\n\n"
                
                # Store in database
                conn = sqlite3.connect(self.db_path)
                cursor = conn.cursor()
                
                # Create a page entry for the PDF
                cursor.execute(
                    """INSERT INTO pages (session_id, url, title, content_hash, status_code, 
                                         content_type, timestamp, screenshot_path) 
                       VALUES (?, ?, ?, ?, ?, ?, ?, ?)""",
                    (session_id, url, os.path.basename(url), hashlib.md5(response.content).hexdigest(), 
                     response.status_code, "application/pdf", datetime.now().isoformat(), pdf_path)
                )
                page_id = cursor.lastrowid
                
                # Store the extracted text
                cursor.execute(
                    "INSERT INTO page_content (page_id, content_type, content, metadata) VALUES (?, ?, ?, ?)",
                    (page_id, "pdf_text", pdf_text, json.dumps({"pdf_pages": len(pdf_reader.pages)}))
                )
                
                conn.commit()
                conn.close()
                
                logger.info(f"Extracted text from PDF: {url}")
                
            except Exception as e:
                logger.error(f"Error extracting text from PDF {url}: {e}")
            
        except Exception as e:
            logger.error(f"Error processing PDF {url}: {e}")
    
    async def close(self):
        """Close the scraper and release resources"""
        if self.browser_tools:
            await self.browser_tools.close()

class ElysianLens:
    """Main application class"""
    
    def __init__(self):
        self.config = Configuration()
        self.proxy_manager = ProxyManager(self.config)
        self.browser_tools = BrowserTools(self.config, self.proxy_manager)
        self.scraper = Scraper(self.config, self.proxy_manager, self.browser_tools)
    
    async def setup(self):
        """Set up the application and its components"""
        # Fetch and verify proxies if enabled
        if self.config.get("USE_PROXIES", "false").lower() == "true":
            await self.proxy_manager.fetch_free_proxies()
            await self.proxy_manager.verify_proxies()
    
    async def scrape(self, url, depth=1, max_pages=10, take_screenshots=True, extract_pdf=True):
        """Scrape a URL with the specified parameters"""
        return await self.scraper.scrape_url(
            url, depth, max_pages, take_screenshots, extract_pdf
        )
    
    async def export_pdf_report(self, session_id):
        """Export a PDF report for a scraping session"""
        conn = sqlite3.connect(self.scraper.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        # Get session info
        cursor.execute("SELECT * FROM scrape_sessions WHERE id = ?", (session_id,))
        session = cursor.fetchone()
        
        if not session:
            logger.error(f"Session ID {session_id} not found")
            conn.close()
            return None
        
        # Get pages
        cursor.execute("SELECT * FROM pages WHERE session_id = ?", (session_id,))
        pages = cursor.fetchall()
        
        # Create report directory
        reports_dir = os.path.join(self.config.data_dir, "exports/reports")
        os.makedirs(reports_dir, exist_ok=True)
        
        # Create report filename
        base_url = session["url"]
        domain = urllib.parse.urlparse(base_url).netloc
        filename = f"report_{domain}_{session_id}.pdf"
        report_path = os.path.join(reports_dir, filename)
        
        # Generate HTML report
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <title>Scraping Report: {domain}</title>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 20px; }}
                h1 {{ color: #2c3e50; }}
                h2 {{ color: #3498db; margin-top: 30px; }}
                .page {{ margin-bottom: 40px; padding: 10px; border: 1px solid #ddd; }}
                .page-title {{ font-size: 18px; font-weight: bold; color: #2c3e50; }}
                .page-url {{ color: #3498db; word-break: break-all; }}
                .page-content {{ margin-top: 15px; }}
                .metadata {{ font-size: 12px; color: #7f8c8d; }}
                .screenshot {{ max-width: 100%; margin-top: 10px; border: 1px solid #ddd; }}
                .links-section {{ margin-top: 20px; }}
                .images-section {{ margin-top: 20px; }}
                table {{ border-collapse: collapse; width: 100%; }}
                th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
                th {{ background-color: #f2f2f2; }}
            </style>
        </head>
        <body>
            <h1>Scraping Report: {domain}</h1>
            <p>Base URL: {base_url}</p>
            <p>Session ID: {session_id}</p>
            <p>Pages Scraped: {session["pages_scraped"]}</p>
            <p>Timestamp: {session["timestamp"]}</p>
            <p>Status: {session["status"]}</p>
            
            <h2>Scraped Pages</h2>
        """
        
        for page in pages:
            page_id = page["id"]
            
            # Get page content
            cursor.execute("SELECT * FROM page_content WHERE page_id = ? AND content_type = 'text'", (page_id,))
            content_row = cursor.fetchone()
            text_content = content_row["content"] if content_row else ""
            
            # Get links
            cursor.execute("SELECT * FROM links WHERE source_page_id = ?", (page_id,))
            links = cursor.fetchall()
            
            # Get images
            cursor.execute("SELECT * FROM images WHERE page_id = ?", (page_id,))
            images = cursor.fetchall()
            
            # Add page to report
            html_content += f"""
            <div class="page">
                <div class="page-title">{page["title"] or "No Title"}</div>
                <div class="page-url">{page["url"]}</div>
                <div class="metadata">Status: {page["status_code"]} | Type: {page["content_type"]} | Timestamp: {page["timestamp"]}</div>
                
                <div class="page-content">
                    <h3>Content:</h3>
                    <p>{text_content[:500]}{"..." if len(text_content) > 500 else ""}</p>
                </div>
            """
            
            # Add screenshot if available
            if page["screenshot_path"] and os.path.exists(page["screenshot_path"]):
                html_content += f"""
                <h3>Screenshot:</h3>
                <img class="screenshot" src="file://{page["screenshot_path"]}" alt="Screenshot of {page["url"]}">
                """
            
            # Add links section
            if links:
                html_content += f"""
                <div class="links-section">
                    <h3>Links ({len(links)}):</h3>
                    <table>
                        <tr>
                            <th>URL</th>
                            <th>Text</th>
                            <th>Type</th>
                        </tr>
                """
                
                for link in links[:20]:  # Limit to 20 links per page
                    link_type = "Internal" if link["is_internal"] else "External"
                    html_content += f"""
                    <tr>
                        <td>{link["target_url"]}</td>
                        <td>{link["link_text"] or ""}</td>
                        <td>{link_type}</td>
                    </tr>
                    """
                
                if len(links) > 20:
                    html_content += f"""
                    <tr>
                        <td colspan="3">... and {len(links) - 20} more links</td>
                    </tr>
                    """
                
                html_content += """
                    </table>
                </div>
                """
            
            # Add images section
            if images:
                html_content += f"""
                <div class="images-section">
                    <h3>Images ({len(images)}):</h3>
                    <table>
                        <tr>
                            <th>URL</th>
                            <th>Alt Text</th>
                            <th>Dimensions</th>
                        </tr>
                """
                
                for image in images[:10]:  # Limit to 10 images per page
                    dimensions = f"{image['width']}x{image['height']}" if image["width"] and image["height"] else "Unknown"
                    html_content += f"""
                    <tr>
                        <td>{image["url"]}</td>
                        <td>{image["alt_text"] or ""}</td>
                        <td>{dimensions}</td>
                    </tr>
                    """
                
                if len(images) > 10:
                    html_content += f"""
                    <tr>
                        <td colspan="3">... and {len(images) - 10} more images</td>
                    </tr>
                    """
                
                html_content += """
                    </table>
                </div>
                """
            
            html_content += """
            </div>
            """
        
        html_content += """
        </body>
        </html>
        """
        
        conn.close()
        
        # Generate PDF using pdfkit
        try:
            options = {
                'page-size': 'A4',
                'margin-top': '20mm',
                'margin-right': '20mm',
                'margin-bottom': '20mm',
                'margin-left': '20mm',
                'encoding': 'UTF-8',
                'no-outline': None
            }
            
            # Save HTML to temporary file
            temp_html = os.path.join(tempfile.gettempdir(), f"report_{session_id}.html")
            with open(temp_html, 'w', encoding='utf-8') as f:
                f.write(html_content)
            
            # Convert HTML to PDF
            pdfkit.from_file(temp_html, report_path, options=options)
            
            # Clean up temporary file
            os.remove(temp_html)
            
            logger.info(f"PDF report created: {report_path}")
            return report_path
            
        except Exception as e:
            logger.error(f"Error generating PDF report: {e}")
            return None
    
    async def generate_site_map(self, session_id):
        """Generate a site map for a scraping session"""
        conn = sqlite3.connect(self.scraper.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        # Get session info
        cursor.execute("SELECT * FROM scrape_sessions WHERE id = ?", (session_id,))
        session = cursor.fetchone()
        
        if not session:
            logger.error(f"Session ID {session_id} not found")
            conn.close()
            return None
        
        # Get pages and links
        cursor.execute("""
        SELECT p.id, p.url, p.title, l.target_url, l.is_internal
        FROM pages p
        LEFT JOIN links l ON p.id = l.source_page_id
        WHERE p.session_id = ?
        """, (session_id,))
        rows = cursor.fetchall()
        
        # Create a site map structure
        site_map = {}
        for row in rows:
            page_id = row["id"]
            page_url = row["url"]
            
            if page_url not in site_map:
                site_map[page_url] = {
                    "title": row["title"],
                    "internal_links": [],
                    "external_links": []
                }
            
            if row["target_url"]:
                if row["is_internal"]:
                    site_map[page_url]["internal_links"].append(row["target_url"])
                else:
                    site_map[page_url]["external_links"].append(row["target_url"])
        
        # Generate markdown site map
        markdown_content = f"# Site Map: {session['url']}\n\n"
        markdown_content += f"- Session ID: {session_id}\n"
        markdown_content += f"- Pages Scraped: {session['pages_scraped']}\n"
        markdown_content += f"- Generated: {datetime.now().isoformat()}\n\n"
        
        markdown_content += "## Pages\n\n"
        
        for url, data in site_map.items():
            markdown_content += f"### {data['title'] or 'No Title'}\n"
            markdown_content += f"- URL: {url}\n"
            
            if data["internal_links"]:
                markdown_content += f"- Internal Links ({len(data['internal_links'])}):\n"
                for link in sorted(set(data["internal_links"]))[:10]:  # Limit to 10 internal links
                    markdown_content += f"  - {link}\n"
                if len(data["internal_links"]) > 10:
                    markdown_content += f"  - ... and {len(data['internal_links']) - 10} more\n"
            
            if data["external_links"]:
                markdown_content += f"- External Links ({len(data['external_links'])}):\n"
                for link in sorted(set(data["external_links"]))[:5]:  # Limit to 5 external links
                    markdown_content += f"  - {link}\n"
                if len(data["external_links"]) > 5:
                    markdown_content += f"  - ... and {len(data['external_links']) - 5} more\n"
            
            markdown_content += "\n"
        
        conn.close()
        
        # Save to file
        sitemap_dir = os.path.join(self.config.data_dir, "exports/text")
        os.makedirs(sitemap_dir, exist_ok=True)
        
        domain = urllib.parse.urlparse(session["url"]).netloc
        filename = f"sitemap_{domain}_{session_id}.md"
        sitemap_path = os.path.join(sitemap_dir, filename)
        
        with open(sitemap_path, 'w', encoding='utf-8') as f:
            f.write(markdown_content)
        
        logger.info(f"Site map created: {sitemap_path}")
        return sitemap_path
    
    async def close(self):
        """Close the application and release resources"""
        if self.scraper:
            await self.scraper.close()

# CLI Application
app = typer.Typer(help=f"ElysianLens: {APP_DESCRIPTION}")

@app.command("scrape")
def scrape_command(
    url: str = typer.Argument(..., help="URL to scrape"),
    depth: int = typer.Option(1, "--depth", "-d", help="Crawling depth"),
    max_pages: int = typer.Option(10, "--max-pages", "-m", help="Maximum number of pages to scrape"),
    screenshots: bool = typer.Option(True, "--screenshots/--no-screenshots", help="Take screenshots of pages"),
    extract_pdf: bool = typer.Option(True, "--extract-pdf/--no-extract-pdf", help="Extract text from PDF files"),
    report: bool = typer.Option(False, "--report", "-r", help="Generate a PDF report after scraping"),
    sitemap: bool = typer.Option(False, "--sitemap", "-s", help="Generate a site map after scraping"),
):
    """Scrape a website with the specified parameters"""
    console.print(f"[bold {COLORS['primary']}]ElysianLens[/] - Scraping: {url}\n")
    
    async def run_scrape():
        app = ElysianLens()
        await app.setup()
        
        with Progress(
            SpinnerColumn(),
            TextColumn("[bold blue]Scraping..."),
            BarColumn(),
            TextColumn("[progress.description]{task.description}"),
            console=console
        ) as progress:
            task = progress.add_task("Starting...", total=None)
            
            try:
                progress.update(task, description=f"Scraping {url} with depth {depth}")
                result = await app.scrape(url, depth, max_pages, screenshots, extract_pdf)
                
                progress.update(task, description=f"Completed. Session ID: {result['session_id']}")
                
                console.print(f"\n[bold {COLORS['success']}]✓[/] Scraping completed:")
                console.print(f"  Session ID: {result['session_id']}")
                console.print(f"  Pages scraped: {result['pages_scraped']}")
                
                # Generate report if requested
                if report:
                    progress.update(task, description="Generating PDF report...")
                    report_path = await app.export_pdf_report(result['session_id'])
                    if report_path:
                        console.print(f"[bold {COLORS['success']}]✓[/] PDF report generated: {report_path}")
                    else:
                        console.print(f"[bold {COLORS['error']}]✗[/] Failed to generate PDF report")
                
                # Generate site map if requested
                if sitemap:
                    progress.update(task, description="Generating site map...")
                    sitemap_path = await app.generate_site_map(result['session_id'])
                    if sitemap_path:
                        console.print(f"[bold {COLORS['success']}]✓[/] Site map generated: {sitemap_path}")
                    else:
                        console.print(f"[bold {COLORS['error']}]✗[/] Failed to generate site map")
                
            except Exception as e:
                console.print(f"[bold {COLORS['error']}]Error:[/] {str(e)}")
                logger.error(f"Error during scraping: {e}")
                logger.error(traceback.format_exc())
            
            finally:
                progress.update(task, description="Cleaning up...")
                await app.close()
    
    asyncio.run(run_scrape())

@app.command("report")
def report_command(
    session_id: int = typer.Argument(..., help="Scraping session ID"),
    format: str = typer.Option("pdf", "--format", "-f", help="Report format (pdf or md)"),
):
    """Generate a report for a previous scraping session"""
    console.print(f"[bold {COLORS['primary']}]ElysianLens[/] - Generating report for session: {session_id}\n")
    
    async def run_report():
        app = ElysianLens()
        
        with Progress(
            SpinnerColumn(),
            TextColumn("[bold blue]Generating report..."),
            BarColumn(),
            TextColumn("[progress.description]{task.description}"),
            console=console
        ) as progress:
            task = progress.add_task("Starting...", total=None)
            
            try:
                if format.lower() == "pdf":
                    progress.update(task, description="Generating PDF report...")
                    report_path = await app.export_pdf_report(session_id)
                    if report_path:
                        console.print(f"[bold {COLORS['success']}]✓[/] PDF report generated: {report_path}")
                    else:
                        console.print(f"[bold {COLORS['error']}]✗[/] Failed to generate PDF report")
                        
                elif format.lower() == "md":
                    progress.update(task, description="Generating site map...")
                    sitemap_path = await app.generate_site_map(session_id)
                    if sitemap_path:
                        console.print(f"[bold {COLORS['success']}]✓[/] Site map generated: {sitemap_path}")
                    else:
                        console.print(f"[bold {COLORS['error']}]✗[/] Failed to generate site map")
                        
                else:
                    console.print(f"[bold {COLORS['error']}]✗[/] Unsupported format: {format}")
                
            except Exception as e:
                console.print(f"[bold {COLORS['error']}]Error:[/] {str(e)}")
                logger.error(f"Error generating report: {e}")
                logger.error(traceback.format_exc())
            
            finally:
                await app.close()
    
    asyncio.run(run_report())

@app.command("interactive")
def interactive_command():
    """Run ElysianLens in interactive mode"""
    # Clear the screen
    console.clear()
    
    # Print the logo
    console.print(Markdown(f"# {APP_NAME} v{APP_VERSION}"))
    console.print(Panel(LLAMA_ASCII_ART, border_style=COLORS["llama"]))
    console.print(f"[bold {COLORS['subtitle']}]{APP_DESCRIPTION}[/]\n")
    
    async def run_interactive():
        app = ElysianLens()
        await app.setup()
        
        try:
            while True:
                console.print("\n[bold]Please select an option:[/]")
                console.print(f"  [bold {COLORS['primary']}]1.[/] Scrape a website")
                console.print(f"  [bold {COLORS['primary']}]2.[/] Generate a report")
                console.print(f"  [bold {COLORS['primary']}]3.[/] Configure settings")
                console.print(f"  [bold {COLORS['primary']}]4.[/] Check proxy status")
                console.print(f"  [bold {COLORS['primary']}]5.[/] Exit")
                
                choice = Prompt.ask("\nEnter your choice", choices=["1", "2", "3", "4", "5"], default="1")
                
                if choice == "1":
                    # Scrape a website
                    url = Prompt.ask("Enter URL to scrape", default="https://example.com")
                    depth = int(Prompt.ask("Enter crawling depth", choices=["1", "2", "3"], default="1"))
                    max_pages = int(Prompt.ask("Maximum pages to scrape", default="10"))
                    screenshots = Confirm.ask("Take screenshots?", default=True)
                    extract_pdf = Confirm.ask("Extract text from PDFs?", default=True)
                    report = Confirm.ask("Generate PDF report after scraping?", default=False)
                    sitemap = Confirm.ask("Generate site map after scraping?", default=False)
                    
                    with Progress(
                        SpinnerColumn(),
                        TextColumn("[bold blue]Scraping..."),
                        BarColumn(),
                        TextColumn("[progress.description]{task.description}"),
                        console=console
                    ) as progress:
                        task = progress.add_task("Starting...", total=None)
                        
                        try:
                            progress.update(task, description=f"Scraping {url} with depth {depth}")
                            result = await app.scrape(url, depth, max_pages, screenshots, extract_pdf)
                            
                            progress.update(task, description=f"Completed. Session ID: {result['session_id']}")
                            
                            console.print(f"\n[bold {COLORS['success']}]✓[/] Scraping completed:")
                            console.print(f"  Session ID: {result['session_id']}")
                            console.print(f"  Pages scraped: {result['pages_scraped']}")
                            
                            # Generate report if requested
                            if report:
                                progress.update(task, description="Generating PDF report...")
                                report_path = await app.export_pdf_report(result['session_id'])
                                if report_path:
                                    console.print(f"[bold {COLORS['success']}]✓[/] PDF report generated: {report_path}")
                                else:
                                    console.print(f"[bold {COLORS['error']}]✗[/] Failed to generate PDF report")
                            
                            # Generate site map if requested
                            if sitemap:
                                progress.update(task, description="Generating site map...")
                                sitemap_path = await app.generate_site_map(result['session_id'])
                                if sitemap_path:
                                    console.print(f"[bold {COLORS['success']}]✓[/] Site map generated: {sitemap_path}")
                                else:
                                    console.print(f"[bold {COLORS['error']}]✗[/] Failed to generate site map")
                            
                        except Exception as e:
                            console.print(f"[bold {COLORS['error']}]Error:[/] {str(e)}")
                
                elif choice == "2":
                    # Generate a report
                    session_id = int(Prompt.ask("Enter session ID"))
                    format_choice = Prompt.ask("Select report format", choices=["pdf", "md"], default="pdf")
                    
                    with Progress(
                        SpinnerColumn(),
                        TextColumn("[bold blue]Generating report..."),
                        console=console
                    ) as progress:
                        task = progress.add_task("Starting...", total=None)
                        
                        try:
                            if format_choice == "pdf":
                                progress.update(task, description="Generating PDF report...")
                                report_path = await app.export_pdf_report(session_id)
                                if report_path:
                                    console.print(f"[bold {COLORS['success']}]✓[/] PDF report generated: {report_path}")
                                else:
                                    console.print(f"[bold {COLORS['error']}]✗[/] Failed to generate PDF report")
                                    
                            elif format_choice == "md":
                                progress.update(task, description="Generating site map...")
                                sitemap_path = await app.generate_site_map(session_id)
                                if sitemap_path:
                                    console.print(f"[bold {COLORS['success']}]✓[/] Site map generated: {sitemap_path}")
                                else:
                                    console.print(f"[bold {COLORS['error']}]✗[/] Failed to generate site map")
                            
                        except Exception as e:
                            console.print(f"[bold {COLORS['error']}]Error:[/] {str(e)}")
                
                elif choice == "3":
                    # Configure settings
                    console.print("\n[bold]Settings:[/]")
                    console.print(f"  Config directory: {app.config.config_dir}")
                    console.print(f"  Environment file: {app.config.env_file}")
                    console.print(f"  Use proxies: {app.config.get('USE_PROXIES', 'false')}")
                    console.print(f"  Stealth mode: {app.config.get('STEALTH_MODE', 'true')}")
                    console.print(f"  API keys configured: {bool(app.config.api_keys)}")
                    
                    console.print("\n[italic]Edit the .env file at the config directory to modify settings.[/]")
                    
                    if Confirm.ask("Update proxy settings?", default=False):
                        use_proxies = Confirm.ask("Use proxies for scraping?", default=False)
                        
                        # Update env file with new setting
                        with open(app.config.env_file, 'r') as f:
                            env_content = f.read()
                        
                        env_content = re.sub(
                            r'USE_PROXIES=.*',
                            f'USE_PROXIES={"true" if use_proxies else "false"}',
                            env_content
                        )
                        
                        with open(app.config.env_file, 'w') as f:
                            f.write(env_content)
                        
                        console.print(f"[bold {COLORS['success']}]✓[/] Proxy settings updated")
                        
                        # Reload configuration
                        app.config = Configuration()
                        app.proxy_manager = ProxyManager(app.config)
                        app.browser_tools = BrowserTools(app.config, app.proxy_manager)
                        app.scraper = Scraper(app.config, app.proxy_manager, app.browser_tools)
                
                elif choice == "4":
                    # Check proxy status
                    console.print("\n[bold]Proxy Status:[/]")
                    
                    if not app.proxy_manager.use_proxies:
                        console.print("[italic]Proxies are disabled.[/]")
                        
                        if Confirm.ask("Fetch and test free proxies?", default=False):
                            await app.proxy_manager.fetch_free_proxies()
                            await app.proxy_manager.verify_proxies()
                    else:
                        http_proxies = len(app.proxy_manager.proxies.get("http", []))
                        https_proxies = len(app.proxy_manager.proxies.get("https", []))
                        socks4_proxies = len(app.proxy_manager.proxies.get("socks4", []))
                        socks5_proxies = len(app.proxy_manager.proxies.get("socks5", []))
                        
                        console.print(f"  HTTP proxies: {http_proxies}")
                        console.print(f"  HTTPS proxies: {https_proxies}")
                        console.print(f"  SOCKS4 proxies: {socks4_proxies}")
                        console.print(f"  SOCKS5 proxies: {socks5_proxies}")
                        
                        if Confirm.ask("Refresh proxies?", default=False):
                            await app.proxy_manager.fetch_free_proxies()
                            await app.proxy_manager.verify_proxies()
                
                elif choice == "5":
                    # Exit
                    console.print(f"\n[bold {COLORS['primary']}]Thank you for using ElysianLens![/]")
                    break
                
                console.print("\nPress Enter to continue...", end="")
                input()
                console.clear()
                console.print(Markdown(f"# {APP_NAME} v{APP_VERSION}"))
        
        finally:
            await app.close()
    
    asyncio.run(run_interactive())

@app.command("version")
def version_command():
    """Display version information"""
    console.print(f"[bold]{APP_NAME}[/] v{APP_VERSION}")
    console.print(APP_DESCRIPTION)

# Main entry point
if __name__ == "__main__":
    app()
EOF
    
    # Make the Python script executable
    chmod +x "$INSTALL_DIR/elysian_lens.py"
    
    # Create a symlink to the script in the user's bin directory
    mkdir -p "$HOME/bin"
    ln -sf "$INSTALL_DIR/elysian_lens.py" "$HOME/bin/elysian_lens"
    
    echo -e "${GREEN}✓${RESET} Application files generated"
    
    show_progress "Application files generation completed" 1
}

# Finalize installation
finalize_installation() {
    echo -e "\n${BLUE}${BOLD}[7/7] Finalizing installation...${RESET}"
    
    # Create a launcher script
    launcher_script="$CONFIG_DIR/elysian_lens_launcher.sh"
    cat > "$launcher_script" << EOF
#!/bin/bash
# ElysianLens Launcher

# Activate virtual environment
source "$INSTALL_DIR/venv/bin/activate"

# Run ElysianLens
python "$INSTALL_DIR/elysian_lens.py" "\$@"
EOF
    
    chmod +x "$launcher_script"
    
    # Create an alias in user's shell configuration if it doesn't exist
    shell_rc="$HOME/.zshrc"
    if [[ ! -f "$shell_rc" ]]; then
        shell_rc="$HOME/.bashrc"
    fi
    
    if [[ -f "$shell_rc" ]]; then
        if ! grep -q "alias elysian_lens" "$shell_rc"; then
            echo "# ElysianLens alias" >> "$shell_rc"
            echo "alias elysian_lens='$launcher_script'" >> "$shell_rc"
            echo -e "${GREEN}✓${RESET} Added alias to $shell_rc"
        else
            echo -e "${GREEN}✓${RESET} Alias already exists in $shell_rc"
        fi
    fi
    
    show_progress "Installation finalized" 1
}

# Main function
main() {
    display_intro
    check_system_requirements
    create_directories
    create_git_commit "feat: Set up project directory structure"
    
    setup_python_environment
    create_git_commit "feat: Configure Python virtual environment"
    
    generate_config_files
    create_git_commit "feat: Add configuration files"
    
    configure_api_keys
    create_git_commit "feat: Configure API integration"
    
    generate_application_files
    create_git_commit "feat: Implement core application functionality"
    
    # Generate comprehensive test suite
    generate_test_files
    create_git_commit "test: Add comprehensive test suite"
    
    # Set up pre-commit hooks for code quality
    setup_pre_commit_hooks
    create_git_commit "chore: Configure pre-commit hooks for code quality"
    
    finalize_installation
    create_git_commit "feat: Finalize installation and command-line tools"
    
    # Create tags for the release
    git tag -a "v1.0.0" -m "Initial release of ElysianLens"
    echo -e "${GREEN}✓${RESET} Created release tag v1.0.0"
    
    echo -e "\n${GREEN}${BOLD}🦙 ElysianLens installation completed!${RESET}\n"
    echo -e "You can now use ElysianLens with the following commands:\n"
    echo -e "${CYAN}$ elysian_lens interactive${RESET} - Launch the interactive mode"
    echo -e "${CYAN}$ elysian_lens scrape https://example.com${RESET} - Scrape a website"
    echo -e "${CYAN}$ elysian_lens report 1 --format pdf${RESET} - Generate a report for session ID 1"
    echo -e "${CYAN}$ elysian_lens version${RESET} - Display version information"
    echo -e "\nFor more options, run: ${CYAN}$ elysian_lens --help${RESET}"
    echo -e "\nIf the alias doesn't work, you may need to restart your terminal or run:"
    echo -e "${CYAN}$ source ~/.zshrc${RESET} or ${CYAN}$ source ~/.bashrc${RESET}"
    echo -e "\nAlternatively, you can run directly using:"
    echo -e "${CYAN}$ $launcher_script${RESET}"
    echo -e "\n${MAGENTA}${BOLD}Happy scraping!${RESET}\n"
    
    echo -e "\n${BLUE}${BOLD}GitHub Repository Setup${RESET}"
    echo -e "Your local git repository has been set up with a professional commit history."
    echo -e "To push this to GitHub, run the following commands:"
    echo -e "${CYAN}$ cd $PROJECT_DIR${RESET}"
    echo -e "${CYAN}$ git remote add origin https://github.com/yourusername/elysian-lens.git${RESET}"
    echo -e "${CYAN}$ git push -u origin main --tags${RESET}"
    
    echo -e "\n${BLUE}${BOLD}Running Tests${RESET}"
    echo -e "To run the test suite and generate a coverage report:"
    echo -e "${CYAN}$ cd $PROJECT_DIR${RESET}"
    echo -e "${CYAN}$ source venv/bin/activate${RESET}"
    echo -e "${CYAN}$ pytest tests/ --cov=src --cov-report=html${RESET}"
    echo -e "This will generate a coverage report in the ${CYAN}htmlcov/${RESET} directory."
}

# Check for root
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}Error: This script should not be run as root${RESET}"
    exit 1
fi

# Run main function
main