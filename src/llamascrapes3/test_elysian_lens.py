#!/usr/bin/env python3
"""
ElysianLens Test Script

This script tests the functionality of the ElysianLens package,
including the scraper, analyzer, and MLX-powered components.
"""

import argparse
import os
import sys
import time
from pathlib import Path


def setup_parser():
    """Set up command line argument parser."""
    parser = argparse.ArgumentParser(description="Test ElysianLens functionality")
    parser.add_argument(
        "--test",
        choices=["all", "scraper", "analyzer", "mlx", "agent", "cli"],
        default="all",
        help="Which test to run",
    )
    parser.add_argument(
        "--url", default="https://example.com", help="URL to test scraping with"
    )
    parser.add_argument(
        "--prompt",
        default="Explain quantum computing in simple terms",
        help="Prompt for text generation",
    )
    parser.add_argument("--verbose", action="store_true", help="Enable verbose output")
    return parser


def test_scraper(url, verbose=False):
    """Test the scraper functionality."""
    print("\n=== Testing WebScraper ===\n")

    try:
        from elysian_lens.scraper import WebScraper

        scraper = WebScraper(
            headless=True,
            stealth=True,
            screenshots=True,
        )

        print(f"Scraping {url}...")
        start_time = time.time()
        result = scraper.scrape(url, depth=1, max_pages=2)
        elapsed = time.time() - start_time

        print(f"Scrape completed in {elapsed:.2f} seconds")
        print(f"Pages scraped: {len(result.get('pages', []))}")
        print(f"Links found: {len(result.get('links', []))}")
        print(f"Images found: {len(result.get('images', []))}")

        if verbose:
            for i, page in enumerate(result.get("pages", [])):
                print(f"\nPage {i+1}:")
                print(f"  URL: {page.get('url', 'N/A')}")
                print(f"  Title: {page.get('title', 'N/A')}")
                text = page.get("text", "")
                print(f"  Text length: {len(text)} characters")
                if text and len(text) > 100:
                    print(f"  Text preview: {text[:100]}...")

        # Test report generation
        report_path = "scrape_report.html"
        if scraper.generate_report(result, report_path):
            print(f"Report generated: {report_path}")

        # Test sitemap generation
        sitemap_path = "sitemap.md"
        if scraper.generate_sitemap(result, sitemap_path):
            print(f"Sitemap generated: {sitemap_path}")

        return True
    except Exception as e:
        print(f"Error during scraper test: {str(e)}")
        if verbose:
            import traceback

            traceback.print_exc()
        return False


def test_analyzer(verbose=False):
    """Test the analyzer functionality."""
    print("\n=== Testing ContentAnalyzer ===\n")

    try:
        from elysian_lens.analyzer import ContentAnalyzer

        analyzer = ContentAnalyzer(use_mlx=True)

        # Test data
        text = """
        ElysianLens is a powerful Python framework that combines advanced web scraping 
        capabilities with state-of-the-art AI analysis powered by MLX on Apple Silicon. 
        It provides a comprehensive toolkit for extracting, processing, and analyzing 
        web data with unprecedented efficiency and intelligence.
        """

        print("Testing sentiment analysis...")
        sentiment = analyzer.analyze_sentiment(text)
        print(f"Sentiment: {sentiment.get('sentiment', 'N/A')}")
        print(f"Score: {sentiment.get('score', 'N/A')}")
        if verbose and "details" in sentiment:
            print(f"Details: {sentiment['details']}")

        print("\nTesting entity extraction...")
        entities = analyzer.extract_entities(text)
        for entity_type, entity_list in entities.items():
            print(f"  {entity_type}: {', '.join(entity_list)}")

        print("\nTesting classification...")
        categories = ["technology", "business", "entertainment", "science"]
        classification = analyzer.classify(text, categories)
        for category, score in classification.items():
            print(f"  {category}: {score:.2f}")

        print("\nTesting summarization...")
        summary = analyzer.summarize(text, max_length=50)
        print(f"Summary: {summary}")

        return True
    except Exception as e:
        print(f"Error during analyzer test: {str(e)}")
        if verbose:
            import traceback

            traceback.print_exc()
        return False


def test_mlx(prompt, verbose=False):
    """Test MLX functionality."""
    print("\n=== Testing MLX Utilities ===\n")

    # Check MLX availability
    try:
        from elysian_lens.mlx_utils import check_mlx_available

        mlx_info = check_mlx_available()
        if not mlx_info.get("available", False):
            print(f"MLX is not available: {mlx_info.get('reason', 'Unknown reason')}")
            return False

        print(f"MLX available: version {mlx_info.get('version', 'unknown')}")
        print(f"Device: {mlx_info.get('name', 'unknown')}")

        # Test text generation if available
        try:
            print("\nTesting text generation...")
            from elysian_lens.mlx_utils import MLXTextGenerator

            generator = MLXTextGenerator(model_name="llama3")

            print(f"Generating text for prompt: '{prompt}'")
            start_time = time.time()
            result = generator.generate(prompt, max_tokens=100)
            elapsed = time.time() - start_time

            print(f"Generation completed in {elapsed:.2f} seconds")
            print(f"Result: {result}")
        except ImportError:
            print("MLXTextGenerator not available")

        # Test embeddings if available
        try:
            print("\nTesting embeddings...")
            from elysian_lens.mlx_utils.embeddings import MLXEmbeddings

            embeddings = MLXEmbeddings(model_name="e5-small")

            texts = ["This is a test", "Another test sentence"]
            print(f"Generating embeddings for {len(texts)} texts")
            start_time = time.time()
            result = embeddings.encode(texts)
            elapsed = time.time() - start_time

            print(f"Embeddings generated in {elapsed:.2f} seconds")
            if result:
                print(f"Embedding dimensions: {len(result[0])}")

                # Test similarity
                similarity = embeddings.similarity(texts[0], texts[1])
                print(f"Similarity between texts: {similarity:.4f}")
        except ImportError:
            print("MLXEmbeddings not available")

        # Test function calling if available
        try:
            print("\nTesting function calling...")
            from elysian_lens.mlx_utils.function_calling import FunctionRegistry

            registry = FunctionRegistry()

            # Define a simple function
            def add(a, b):
                return a + b

            # Register the function
            registry.register(
                func=add,
                description="Add two numbers",
                parameter_schema={
                    "type": "object",
                    "properties": {"a": {"type": "number"}, "b": {"type": "number"}},
                    "required": ["a", "b"],
                },
            )

            # Get function schemas
            schemas = registry.get_schemas()
            print(f"Function schemas: {len(schemas)}")

            # Test executing a function
            function_name = "add"
            parameters = {"a": 5, "b": 3}
            result = registry.execute(function_name, parameters)
            print(f"Function result: {result}")
        except ImportError:
            print("Function calling utilities not available")

        return True
    except Exception as e:
        print(f"Error during MLX test: {str(e)}")
        if verbose:
            import traceback

            traceback.print_exc()
        return False


def test_agent(prompt, verbose=False):
    """Test agent functionality."""
    print("\n=== Testing Agent ===\n")

    try:
        from elysian_lens.agent import Agent

        from elysian_lens import tools

        # Check if MLX is available for the agent
        try:
            from elysian_lens.mlx_utils import MLXTextGenerator

            llm = MLXTextGenerator(model_name="llama3")
            agent = Agent(llm_provider=llm, verbose=verbose)

            # Register tools
            print("Registering tools from tools module...")
            agent.create_tools_from_module(tools)

            # Run the agent
            print(f"Running agent with prompt: '{prompt}'")

            system_prompt = (
                "You are a helpful assistant that can use tools to find information."
            )
            start_time = time.time()
            result = agent.run(
                user_input=prompt,
                system_prompt=system_prompt,
            )
            elapsed = time.time() - start_time

            print(f"Agent completed in {elapsed:.2f} seconds")
            print(f"Function calls: {len(result.get('function_calls', []))}")

            if verbose:
                print("\nFunction calls:")
                for call in result.get("function_calls", []):
                    print(f"  {call['function']}({call['parameters']})")

            print(f"\nResponse: {result['response']}")

            return True
        except ImportError:
            print("MLX is not available for the agent test")
            return False
    except Exception as e:
        print(f"Error during agent test: {str(e)}")
        if verbose:
            import traceback

            traceback.print_exc()
        return False


def test_cli(verbose=False):
    """Test CLI functionality."""
    print("\n=== Testing CLI ===\n")

    try:
        import subprocess

        # Test CLI version command
        print("Testing CLI version command...")
        result = subprocess.run(
            ["python", "-m", "elysian_lens", "version"],
            check=True,
            capture_output=True,
            text=True,
        )
        print(f"Output: {result.stdout.strip()}")

        # Skip further CLI tests for brevity
        print("CLI test completed (minimal test only)")

        return True
    except Exception as e:
        print(f"Error during CLI test: {str(e)}")
        if verbose:
            import traceback

            traceback.print_exc()
        return False


def main():
    """Run the tests."""
    parser = setup_parser()
    args = parser.parse_args()

    test_func = args.test
    url = args.url
    prompt = args.prompt
    verbose = args.verbose

    print(f"ElysianLens Test Script")
    print(f"Testing: {test_func}")

    results = {}

    if test_func == "all" or test_func == "scraper":
        results["scraper"] = test_scraper(url, verbose)

    if test_func == "all" or test_func == "analyzer":
        results["analyzer"] = test_analyzer(verbose)

    if test_func == "all" or test_func == "mlx":
        results["mlx"] = test_mlx(prompt, verbose)

    if test_func == "all" or test_func == "agent":
        results["agent"] = test_agent(prompt, verbose)

    if test_func == "all" or test_func == "cli":
        results["cli"] = test_cli(verbose)

    # Display summary
    print("\n=== Test Results ===\n")
    for name, passed in results.items():
        status = "PASS" if passed else "FAIL"
        print(f"{name}: {status}")

    # Return 0 if all tests passed, 1 otherwise
    success = all(results.values())
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
