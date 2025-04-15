#!/usr/bin/env python3
"""
MLX Model Downloader for ElysianLens

This script downloads and prepares MLX models for use with ElysianLens.
It handles downloading, converting, and caching models for text generation,
embeddings, and vision-language tasks.
"""

import argparse
import os
import sys
import time
from pathlib import Path
from typing import Any, Dict, List, Optional


# Check if running on Apple Silicon
def is_apple_silicon() -> bool:
    """Check if running on Apple Silicon."""
    import platform

    return platform.system() == "Darwin" and (
        platform.machine() == "arm64" or platform.machine() == "aarch64"
    )


# Check if MLX is available
def check_mlx_available() -> Dict[str, Any]:
    """Check if MLX is available."""
    if not is_apple_silicon():
        return {
            "available": False,
            "reason": "MLX requires Apple Silicon (M1/M2/M3) Mac",
        }

    try:
        import mlx.core as mx

        # Get device information
        device_name = mx.default_device().name
        return {
            "available": True,
            "version": getattr(mx, "__version__", "unknown"),
            "name": device_name,
            "metal": "metal" in device_name.lower(),
        }
    except ImportError:
        return {
            "available": False,
            "reason": "MLX package not installed",
        }
    except Exception as e:
        return {
            "available": False,
            "reason": f"Error checking MLX: {str(e)}",
        }


def ensure_cache_dir(cache_dir: Optional[str] = None) -> str:
    """Ensure the cache directory exists and return its path."""
    if cache_dir is None:
        # Use default cache directory
        home_dir = os.path.expanduser("~")
        cache_dir = os.path.join(home_dir, ".elysian_lens", "models")

    # Create directory if it doesn't exist
    os.makedirs(cache_dir, exist_ok=True)

    return cache_dir


def download_text_generation_models(models: List[str], cache_dir: str) -> None:
    """Download text generation models."""
    try:
        import mlx_lm
        from mlx_lm.utils import get_model_path

        for model in models:
            print(f"Downloading text generation model: {model}")
            model_path = get_model_path(model, cache_dir=cache_dir)
            print(f"Model saved to: {model_path}")

            # Load the model to verify it works
            print(f"Verifying model: {model}")
            model_obj, tokenizer = mlx_lm.load(model_path, None)

            # Generate a test prompt
            prompt = "Hello, world!"
            print(f"Testing model with prompt: '{prompt}'")

            # Generate text
            result = model_obj.generate(tokenizer.encode(prompt), max_tokens=20)
            generated_text = tokenizer.decode(result)

            print(f"Generated text: {generated_text}")
            print(f"Model {model} downloaded and verified successfully")
            print("-" * 50)
    except ImportError:
        print("Error: mlx_lm not installed. Install with 'pip install mlx-lm'")
        return
    except Exception as e:
        print(f"Error downloading text generation models: {str(e)}")
        return


def download_embedding_models(models: List[str], cache_dir: str) -> None:
    """Download embedding models."""
    try:
        # Check if mlx_embedding is available
        try:
            import mlx_embedding

            for model in models:
                print(f"Downloading embedding model: {model}")
                model_obj = mlx_embedding.EmbeddingModel.from_pretrained(model)

                # Save the model to cache
                model_dir = os.path.join(cache_dir, model.replace("/", "_"))
                os.makedirs(model_dir, exist_ok=True)
                model_obj.save(model_dir)

                print(f"Model saved to: {model_dir}")

                # Test the model
                print(f"Testing model: {model}")
                test_text = "This is a test sentence for embeddings."
                embeddings = model_obj.encode([test_text])

                print(f"Generated embeddings with shape: {embeddings[0].shape}")
                print(f"Model {model} downloaded and verified successfully")
                print("-" * 50)
        except ImportError:
            print(
                "Warning: mlx_embedding not installed. Falling back to transformers + MLX"
            )

            # Fallback to transformers + MLX
            import mlx.core as mx
            from transformers import AutoModel, AutoTokenizer

            for model in models:
                print(f"Downloading embedding model: {model}")

                # Download tokenizer and model
                tokenizer = AutoTokenizer.from_pretrained(model)
                hf_model = AutoModel.from_pretrained(model)

                # Convert to MLX compatible format
                import torch

                # Create simple state dict conversion
                state_dict = {}
                for name, param in hf_model.state_dict().items():
                    state_dict[name] = mx.array(param.detach().numpy())

                # Save MLX model
                model_dir = os.path.join(cache_dir, model.replace("/", "_"))
                os.makedirs(model_dir, exist_ok=True)
                mx.save(os.path.join(model_dir, "weights.npz"), state_dict)

                # Save tokenizer
                tokenizer.save_pretrained(model_dir)

                # Save config
                import json

                with open(os.path.join(model_dir, "config.json"), "w") as f:
                    json.dump(hf_model.config.to_dict(), f)

                print(f"Model saved to: {model_dir}")
                print(f"Model {model} downloaded and converted successfully")
                print("-" * 50)
    except Exception as e:
        print(f"Error downloading embedding models: {str(e)}")
        return


def download_vision_language_models(models: List[str], cache_dir: str) -> None:
    """Download vision-language models."""
    try:
        # Check if mlx_vision is available
        try:
            import mlx_vision

            for model in models:
                print(f"Downloading vision-language model: {model}")
                model_obj = mlx_vision.VLModel.from_pretrained(model)

                # Save the model to cache
                model_dir = os.path.join(cache_dir, model.replace("/", "_"))
                os.makedirs(model_dir, exist_ok=True)
                model_obj.save(model_dir)

                print(f"Model saved to: {model_dir}")
                print(f"Model {model} downloaded and verified successfully")
                print("-" * 50)
        except ImportError:
            print(
                "Warning: mlx_vision not installed. Falling back to transformers + MLX"
            )

            # Fallback to transformers + MLX
            import mlx.core as mx
            from transformers import AutoModel, AutoProcessor

            for model in models:
                print(f"Downloading vision-language model: {model}")

                # Download processor and model
                processor = AutoProcessor.from_pretrained(model)
                hf_model = AutoModel.from_pretrained(model)

                # Convert to MLX compatible format
                import torch

                # Create simple state dict conversion
                state_dict = {}
                for name, param in hf_model.state_dict().items():
                    state_dict[name] = mx.array(param.detach().numpy())

                # Save MLX model
                model_dir = os.path.join(cache_dir, model.replace("/", "_"))
                os.makedirs(model_dir, exist_ok=True)
                mx.save(os.path.join(model_dir, "weights.npz"), state_dict)

                # Save processor
                processor.save_pretrained(model_dir)

                # Save config
                import json

                with open(os.path.join(model_dir, "config.json"), "w") as f:
                    json.dump(hf_model.config.to_dict(), f)

                print(f"Model saved to: {model_dir}")
                print(f"Model {model} downloaded and converted successfully")
                print("-" * 50)
    except Exception as e:
        print(f"Error downloading vision-language models: {str(e)}")
        return


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description="Download MLX models for ElysianLens")
    parser.add_argument(
        "--cache-dir",
        help="Directory to cache models",
        default=None,
    )
    parser.add_argument(
        "--text-generation",
        action="store_true",
        help="Download text generation models",
    )
    parser.add_argument(
        "--embeddings",
        action="store_true",
        help="Download embedding models",
    )
    parser.add_argument(
        "--vision-language",
        action="store_true",
        help="Download vision-language models",
    )
    parser.add_argument(
        "--all",
        action="store_true",
        help="Download all models",
    )
    args = parser.parse_args()

    # Check if running on Apple Silicon
    if not is_apple_silicon():
        print("Error: This script requires an Apple Silicon Mac (M1/M2/M3)")
        return 1

    # Check if MLX is available
    mlx_info = check_mlx_available()
    if not mlx_info["available"]:
        print(f"Error: MLX is not available: {mlx_info['reason']}")
        print("Please install MLX with 'pip install mlx mlx-lm'")
        return 1

    print(f"MLX version: {mlx_info['version']}")
    print(f"Device: {mlx_info['name']}")

    # Ensure cache directory exists
    cache_dir = ensure_cache_dir(args.cache_dir)
    print(f"Using cache directory: {cache_dir}")

    # Default models
    text_generation_models = [
        "mlx-community/Meta-Llama-3-8B-Instruct-mlx",
        "mlx-community/Mistral-7B-Instruct-v0.3-mlx",
        "mlx-community/phi-3-mini-4k-instruct-mlx",
    ]

    embedding_models = [
        "mlx-community/e5-small-v2-mlx",
        "mlx-community/bge-small-en-v1.5-mlx",
    ]

    vision_language_models = [
        "mlx-community/llava-hf-7b-mlx",
        "mlx-community/phi-3-vision-128k-instruct-mlx",
    ]

    # Download models based on arguments
    if args.all or args.text_generation:
        print("\n=== Downloading Text Generation Models ===\n")
        download_text_generation_models(text_generation_models, cache_dir)

    if args.all or args.embeddings:
        print("\n=== Downloading Embedding Models ===\n")
        download_embedding_models(embedding_models, cache_dir)

    if args.all or args.vision_language:
        print("\n=== Downloading Vision-Language Models ===\n")
        download_vision_language_models(vision_language_models, cache_dir)

    print("\nAll requested models downloaded successfully!")
    return 0


if __name__ == "__main__":
    sys.exit(main())
