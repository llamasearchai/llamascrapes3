#!/usr/bin/env python3
"""
ElysianLens Runner Script

This script provides a convenient way to run the ElysianLens system,
including installing dependencies, launching the interactive mode,
and testing the system.
"""

import argparse
import os
import subprocess
import sys
from pathlib import Path


def setup_parser():
    """Set up the command-line argument parser."""
    parser = argparse.ArgumentParser(description="Run ElysianLens")
    parser.add_argument(
        "--mode",
        choices=["interactive", "test", "scrape", "analyze", "generate", "agent"],
        default="interactive",
        help="Mode to run in",
    )
    parser.add_argument(
        "--install", action="store_true", help="Install dependencies first"
    )
    parser.add_argument("--url", help="URL to scrape (for scrape mode)")
    parser.add_argument("--file", help="File to analyze (for analyze mode)")
    parser.add_argument(
        "--prompt", help="Prompt for text generation or agent (for generate/agent mode)"
    )
    parser.add_argument(
        "--model",
        default="llama3",
        help="Model to use for generation (for generate mode)",
    )
    parser.add_argument("--output", help="Output file path")
    return parser


def install_dependencies(mlx=True, all_deps=False):
    """Install ElysianLens dependencies."""
    print("Installing ElysianLens dependencies...")

    # Setup commands
    base_cmd = [sys.executable, "-m", "pip", "install", "-e", "."]
    mlx_cmd = [sys.executable, "-m", "pip", "install", "-e", ".[mlx]"]
    all_cmd = [sys.executable, "-m", "pip", "install", "-e", ".[all]"]

    # Always install base dependencies
    print("Installing base dependencies...")
    subprocess.run(base_cmd, check=True)

    # Install MLX if requested and on Apple Silicon
    if mlx:
        print("Checking for Apple Silicon...")
        is_apple_silicon = sys.platform == "darwin" and (
            os.uname().machine == "arm64" or os.uname().machine == "aarch64"
        )

        if is_apple_silicon:
            print("Apple Silicon detected, installing MLX dependencies...")
            subprocess.run(mlx_cmd, check=True)
        else:
            print("Not running on Apple Silicon, skipping MLX dependencies")

    # Install all dependencies if requested
    if all_deps:
        print("Installing all optional dependencies...")
        subprocess.run(all_cmd, check=True)

    print("Dependencies installed successfully")


def run_interactive_mode():
    """Run ElysianLens in interactive mode."""
    print("Starting ElysianLens in interactive mode...")
    subprocess.run([sys.executable, "-m", "elysian_lens", "interactive"], check=True)


def run_test_mode():
    """Run ElysianLens tests."""
    print("Running ElysianLens tests...")
    subprocess.run([sys.executable, "test_elysian_lens.py", "--verbose"], check=True)


def run_scrape_mode(url, output=None):
    """Run ElysianLens in scrape mode."""
    if not url:
        print("Error: URL is required for scrape mode")
        return 1

    print(f"Scraping URL: {url}")
    cmd = [sys.executable, "-m", "elysian_lens", "scrape", url]

    if output:
        cmd.extend(["--output", output])

    subprocess.run(cmd, check=True)
    return 0


def run_analyze_mode(file, output=None):
    """Run ElysianLens in analyze mode."""
    if not file:
        print("Error: File is required for analyze mode")
        return 1

    print(f"Analyzing file: {file}")
    cmd = [sys.executable, "-m", "elysian_lens", "analyze", file]

    if output:
        cmd.extend(["--output", output])

    subprocess.run(cmd, check=True)
    return 0


def run_generate_mode(prompt, model, output=None):
    """Run ElysianLens in generate mode."""
    if not prompt:
        print("Error: Prompt is required for generate mode")
        return 1

    print(f"Generating text with model {model}")
    cmd = [
        sys.executable,
        "-m",
        "elysian_lens",
        "generate-text",
        prompt,
        "--model",
        model,
    ]

    if output:
        cmd.extend(["--output", output])

    subprocess.run(cmd, check=True)
    return 0


def run_agent_mode(prompt, output=None):
    """Run ElysianLens in agent mode."""
    if not prompt:
        print("Error: Prompt is required for agent mode")
        return 1

    print(f"Running agent with prompt: {prompt}")
    cmd = [sys.executable, "-m", "elysian_lens", "agent", prompt]

    if output:
        cmd.extend(["--output", output])

    subprocess.run(cmd, check=True)
    return 0


def main():
    """Main entry point."""
    parser = setup_parser()
    args = parser.parse_args()

    # Print welcome message
    print("=" * 60)
    print("ElysianLens - Advanced Web Scraping & AI-Enhanced Data Analysis")
    print("=" * 60)

    # Install dependencies if requested
    if args.install:
        install_dependencies(mlx=True, all_deps=False)

    # Run in the selected mode
    try:
        if args.mode == "interactive":
            run_interactive_mode()
        elif args.mode == "test":
            run_test_mode()
        elif args.mode == "scrape":
            return run_scrape_mode(args.url, args.output)
        elif args.mode == "analyze":
            return run_analyze_mode(args.file, args.output)
        elif args.mode == "generate":
            return run_generate_mode(args.prompt, args.model, args.output)
        elif args.mode == "agent":
            return run_agent_mode(args.prompt, args.output)
    except subprocess.CalledProcessError as e:
        print(f"Error: Command failed with exit code {e.returncode}")
        return e.returncode
    except Exception as e:
        print(f"Error: {str(e)}")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
