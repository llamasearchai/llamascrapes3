#!/bin/bash
# ElysianLens Comprehensive Setup Script
# This script handles complete installation and configuration of ElysianLens

set -e  # Exit on error

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print colored message
print_message() {
    echo -e "${BLUE}[ElysianLens]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_step() {
    echo -e "${CYAN}[STEP $1]${NC} $2"
}

# Check if Python 3.9+ is installed
check_python() {
    print_step "1" "Checking Python version..."
    
    if command -v python3 &>/dev/null; then
        python_cmd="python3"
    elif command -v python &>/dev/null; then
        python_cmd="python"
    else
        print_error "Python not found. Please install Python 3.9 or higher."
        exit 1
    fi
    
    # Check Python version
    python_version=$($python_cmd -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    print_message "Found Python $python_version"
    
    # Check if version is at least 3.9
    if [[ $(echo "$python_version < 3.9" | bc) -eq 1 ]]; then
        print_error "Python 3.9 or higher is required (found $python_version)."
        exit 1
    fi
    
    print_success "Python $python_version is compatible."
}

# Check if running on Apple Silicon
check_apple_silicon() {
    print_step "2" "Checking for Apple Silicon..."
    
    if [[ "$(uname)" == "Darwin" ]]; then
        chip=$(uname -m)
        if [[ "$chip" == "arm64" ]]; then
            print_success "Running on Apple Silicon ($chip)."
            export IS_APPLE_SILICON=1
            return 0
        else
            print_warning "Not running on Apple Silicon ($chip). MLX features will not be available."
            export IS_APPLE_SILICON=0
            return 1
        fi
    else
        print_warning "Not running on macOS. MLX features will not be available."
        export IS_APPLE_SILICON=0
        return 1
    fi
}

# Setup Python virtual environment
setup_venv() {
    print_step "3" "Setting up Python virtual environment..."
    
    if [ -d ".venv" ]; then
        print_message "Virtual environment already exists."
    else
        $python_cmd -m venv .venv
        print_success "Created virtual environment."
    fi
    
    # Activate virtual environment
    if [[ "$(uname)" == "Darwin" || "$(uname)" == "Linux" ]]; then
        source .venv/bin/activate
    else
        # Windows
        source .venv/Scripts/activate
    fi
    
    print_success "Virtual environment activated."
    
    # Upgrade pip and basic tools
    pip install --upgrade pip setuptools wheel
}

# Install dependencies
install_deps() {
    print_step "4" "Installing dependencies..."
    
    # Install base package
    pip install -e .
    print_success "Installed base dependencies."
    
    # Install MLX if on Apple Silicon
    if [[ "$IS_APPLE_SILICON" -eq 1 ]]; then
        print_message "Installing MLX dependencies..."
        pip install -e ".[mlx]"
        
        # Also install optional MLX packages
        pip install mlx-lm mlx-vision-language mlx-embeddings transformers accelerate
        print_success "Installed MLX dependencies."
    fi
    
    # Install integration dependencies
    print_message "Installing integration dependencies..."
    pip install -e ".[integrations]"
    print_success "Installed integration dependencies."
    
    # Install development dependencies if requested
    if [[ "$INSTALL_DEV" -eq 1 ]]; then
        print_message "Installing development dependencies..."
        pip install -e ".[dev]"
        print_success "Installed development dependencies."
    fi
}

# Install Playwright browsers if needed
install_playwright() {
    print_step "5" "Setting up Playwright for web scraping..."
    
    if pip list | grep -q playwright; then
        print_message "Installing Playwright browsers..."
        playwright install
        print_success "Playwright browsers installed."
    else
        print_warning "Playwright not installed, skipping browser installation."
    fi
}

# Download MLX models
download_mlx_models() {
    if [[ "$IS_APPLE_SILICON" -eq 1 ]]; then
        print_step "6" "Downloading MLX models..."
        
        # Make sure the script is executable
        chmod +x download_mlx_models.py
        
        # Download text generation models
        print_message "Downloading text generation models..."
        ./download_mlx_models.py --text-generation
        
        # Download embedding models
        print_message "Downloading embedding models..."
        ./download_mlx_models.py --embeddings
        
        # Ask if user wants to download vision-language models (larger)
        read -p "Do you want to download vision-language models (larger size)? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_message "Downloading vision-language models..."
            ./download_mlx_models.py --vision-language
        fi
        
        print_success "MLX models downloaded successfully."
    else
        print_warning "Skipping MLX model download (not on Apple Silicon)."
    fi
}

# Run tests
run_tests() {
    print_step "7" "Running tests..."
    
    # Make the test script executable
    chmod +x test_elysian_lens.py
    
    # Run the tests
    ./test_elysian_lens.py --test scraper
    
    # Print success message
    print_success "Basic tests passed successfully."
}

# Configure system
configure_system() {
    print_step "8" "Configuring ElysianLens..."
    
    # Create data directories
    mkdir -p ~/.elysian_lens/data
    mkdir -p ~/.elysian_lens/cache
    mkdir -p ~/.elysian_lens/logs
    
    # Create basic configuration
    mkdir -p elysian_lens/config
    
    # Set permissions for scripts
    chmod +x elysian_lens_start.command
    chmod +x install_and_run.sh
    chmod +x run_elysian_lens.py
    
    print_success "ElysianLens configured successfully."
}

# Main execution
main() {
    clear
    echo "=================================================="
    echo "         ElysianLens Complete Setup Script        "
    echo "=================================================="
    echo
    
    # Ask for development mode
    read -p "Do you want to install development dependencies? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        export INSTALL_DEV=1
    else
        export INSTALL_DEV=0
    fi
    
    # Check requirements
    check_python
    check_apple_silicon
    
    # Setup and install
    setup_venv
    install_deps
    install_playwright
    download_mlx_models
    configure_system
    
    # Ask if user wants to run tests
    read -p "Do you want to run basic tests? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_tests
    fi
    
    echo
    echo "=================================================="
    echo "         ElysianLens Setup Complete!              "
    echo "=================================================="
    echo
    echo "To start ElysianLens, run one of the following:"
    echo "  - ./elysian_lens_start.command (macOS)"
    echo "  - ./install_and_run.sh (any platform)"
    echo "  - python -m elysian_lens interactive"
    echo
    
    # Ask if user wants to start ElysianLens now
    read -p "Do you want to start ElysianLens now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [[ "$(uname)" == "Darwin" ]]; then
            ./elysian_lens_start.command
        else
            ./install_and_run.sh
        fi
    fi
}

# Execute main function
main 