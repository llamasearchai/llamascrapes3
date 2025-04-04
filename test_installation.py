#!/usr/bin/env python3
"""
ElysianLens Installation Test Script

This script verifies that ElysianLens is properly installed and configured.
It checks for required dependencies and tests basic functionality.
"""

import os
import sys
import platform
import importlib.util
from typing import Dict, List, Any

def check_python_version() -> bool:
    """Check if Python version is 3.9 or higher."""
    major, minor = sys.version_info.major, sys.version_info.minor
    if major < 3 or (major == 3 and minor < 9):
        print(f"❌ Python 3.9+ required, found {major}.{minor}")
        return False
    print(f"✅ Python version: {major}.{minor}")
    return True

def check_package_installed(package_name: str) -> bool:
    """Check if a package is installed."""
    spec = importlib.util.find_spec(package_name)
    if spec is None:
        print(f"❌ {package_name} not installed")
        return False
    print(f"✅ {package_name} installed")
    return True

def check_apple_silicon() -> bool:
    """Check if running on Apple Silicon."""
    is_apple_silicon = (
        platform.system() == "Darwin" and 
        (platform.machine() == "arm64" or platform.machine() == "aarch64")
    )
    if is_apple_silicon:
        print("✅ Running on Apple Silicon")
    else:
        print("ℹ️ Not running on Apple Silicon (MLX features will not be available)")
    return is_apple_silicon

def check_mlx_available() -> bool:
    """Check if MLX is available."""
    if not check_apple_silicon():
        return False
    
    try:
        import mlx.core as mx
        print(f"✅ MLX installed (version: {getattr(mx, '__version__', 'unknown')})")
        return True
    except ImportError:
        print("❌ MLX not installed")
        return False

def check_elysian_lens() -> bool:
    """Check if ElysianLens is properly installed."""
    try:
        import elysian_lens
        print(f"✅ ElysianLens installed (version: {elysian_lens.__version__})")
        
        # Check core components
        from elysian_lens.scraper import WebScraper
        print("✅ WebScraper available")
        
        from elysian_lens.analyzer import ContentAnalyzer
        print("✅ ContentAnalyzer available")
        
        # Check if agent is available
        try:
            from elysian_lens.agent import Agent
            print("✅ Agent available")
        except ImportError:
            print("❌ Agent not available")
        
        # Get system info
        if hasattr(elysian_lens, 'get_system_info'):
            system_info = elysian_lens.get_system_info()
            print("\nSystem Information:")
            for key, value in system_info.items():
                print(f"  {key}: {value}")
        
        return True
    except ImportError:
        print("❌ ElysianLens not installed")
        return False

def check_required_packages() -> bool:
    """Check if required packages are installed."""
    required_packages = [
        "typer",
        "rich",
        "requests",
        "beautifulsoup4",
        "pandas",
        "pydantic",
    ]
    
    all_installed = True
    for package in required_packages:
        if not check_package_installed(package):
            all_installed = False
    
    return all_installed

def check_optional_packages() -> Dict[str, bool]:
    """Check if optional packages are installed."""
    optional_packages = {
        "playwright": "Web automation",
        "selenium": "Web automation",
        "openai": "OpenAI API",
        "anthropic": "Anthropic API",
        "llama_index": "Document indexing",
        "transformers": "Hugging Face models",
    }
    
    results = {}
    print("\nOptional Packages:")
    for package, description in optional_packages.items():
        spec = importlib.util.find_spec(package)
        installed = spec is not None
        results[package] = installed
        status = "✅" if installed else "❌"
        print(f"{status} {package} ({description})")
    
    return results

def main():
    """Run all checks."""
    print("=" * 60)
    print("ElysianLens Installation Test")
    print("=" * 60)
    print()
    
    python_ok = check_python_version()
    apple_silicon = check_apple_silicon()
    if apple_silicon:
        mlx_available = check_mlx_available()
    
    print("\nRequired Packages:")
    packages_ok = check_required_packages()
    
    optional_packages = check_optional_packages()
    
    print("\nElysianLens:")
    elysian_lens_ok = check_elysian_lens()
    
    print("\nSummary:")
    if python_ok and packages_ok and elysian_lens_ok:
        print("✅ ElysianLens is properly installed and configured!")
        if apple_silicon and not mlx_available:
            print("⚠️  MLX is not installed. Install it to enable AI features.")
    else:
        print("❌ There are issues with the ElysianLens installation.")
        print("   Please check the messages above for details.")
    
    print("\nTo start ElysianLens, run one of the following:")
    print("  - ./elysian_lens_start.command (macOS)")
    print("  - ./install_and_run.sh (any platform)")
    print("  - python -m elysian_lens interactive")
    
    return 0 if python_ok and packages_ok and elysian_lens_ok else 1

if __name__ == "__main__":
    sys.exit(main()) 