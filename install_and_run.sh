#!/bin/bash
# ElysianLens Installation and Execution Script
# This script handles installation, setup, and running of ElysianLens

set -e  # Exit on error

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
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

# Check if Python 3.9+ is installed
check_python() {
    print_message "Checking Python version..."
    
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
    print_message "Checking for Apple Silicon..."
    
    if [[ "$(uname)" == "Darwin" ]]; then
        chip=$(uname -m)
        if [[ "$chip" == "arm64" ]]; then
            print_success "Running on Apple Silicon ($chip)."
            return 0
        else
            print_warning "Not running on Apple Silicon ($chip). MLX features will not be available."
            return 1
        fi
    else
        print_warning "Not running on macOS. MLX features will not be available."
        return 1
    fi
}

# Setup Python virtual environment
setup_venv() {
    print_message "Setting up Python virtual environment..."
    
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
}

# Install dependencies
install_deps() {
    print_message "Installing dependencies..."
    
    # Upgrade pip
    pip install --upgrade pip
    
    # Install base package
    pip install -e .
    print_success "Installed base dependencies."
    
    # Install MLX if on Apple Silicon
    if check_apple_silicon; then
        print_message "Installing MLX dependencies..."
        pip install -e ".[mlx]"
        print_success "Installed MLX dependencies."
    fi
}

# Install Playwright browsers if needed
install_playwright() {
    print_message "Setting up Playwright for web scraping..."
    
    if pip list | grep -q playwright; then
        print_message "Installing Playwright browsers..."
        playwright install
        print_success "Playwright browsers installed."
    else
        print_warning "Playwright not installed, skipping browser installation."
    fi
}

# Run ElysianLens
run_elysian_lens() {
    print_message "Running ElysianLens..."
    python run_elysian_lens.py "$@"
}

# Main execution
main() {
    echo "=================================================="
    echo "         ElysianLens Installation & Setup         "
    echo "=================================================="
    
    check_python
    setup_venv
    install_deps
    install_playwright
    
    echo ""
    echo "=================================================="
    echo "         ElysianLens Ready to Run                 "
    echo "=================================================="
    echo ""
    
    # Run ElysianLens with all arguments passed to this script
    run_elysian_lens "$@"
}

# Execute main function with all arguments
main "$@" 