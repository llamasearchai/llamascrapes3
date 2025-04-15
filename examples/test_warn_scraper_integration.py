#!/usr/bin/env python3
"""
Example script to test the Warn-Scraper integration.

This script demonstrates how to use the Warn-Scraper integration
for web scraping with anti-detection capabilities.
"""

import argparse
import json
import logging
import os
import sys
from typing import List

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)],
)

try:
    from elysian_lens.warn_scraper_integration import WarnScraperClient, is_available
except ImportError:
    print(
        "Error: Elysian Lens package not found. Please install with 'pip install -e .'"
    )
    sys.exit(1)


def save_results(results, output_dir):
    """Save scraping results to files."""
    os.makedirs(output_dir, exist_ok=True)

    # Save full results as JSON
    with open(os.path.join(output_dir, "results.json"), "w") as f:
        json.dump(results, f, indent=2)

    # Save HTML content
    for i, result in enumerate(results):
        if "html" in result:
            with open(os.path.join(output_dir, f"page_{i+1}.html"), "w") as f:
                f.write(result.get("content", ""))

        # Save extracted text
        if "content" in result:
            with open(os.path.join(output_dir, f"text_{i+1}.txt"), "w") as f:
                f.write(result.get("content", ""))


def main():
    """Main function to test the Warn-Scraper integration."""
    parser = argparse.ArgumentParser(description="Test Warn-Scraper integration")
    parser.add_argument("urls", nargs="+", help="URLs to scrape")
    parser.add_argument(
        "--output-dir",
        default="./scraped_data",
        help="Output directory for scraped data",
    )
    parser.add_argument(
        "--extract-links", action="store_true", help="Extract links from scraped pages"
    )
    parser.add_argument(
        "--extract-images",
        action="store_true",
        help="Extract images from scraped pages",
    )
    parser.add_argument(
        "--download-images", action="store_true", help="Download extracted images"
    )
    parser.add_argument(
        "--proxy", help="Proxy URL in format protocol://user:pass@host:port"
    )
    parser.add_argument(
        "--timeout", type=int, default=30, help="Request timeout in seconds"
    )
    parser.add_argument(
        "--retry-count",
        type=int,
        default=3,
        help="Number of retries for failed requests",
    )
    args = parser.parse_args()

    # Check if warn-scraper is available
    if not is_available():
        print(
            "Error: warn-scraper is not available. Install it with 'pip install warn-scraper'."
        )
        sys.exit(1)

    # Initialize client
    client = WarnScraperClient(
        proxy=args.proxy,
        timeout=args.timeout,
        retry_count=args.retry_count,
    )

    # Scrape URLs
    print(f"Scraping {len(args.urls)} URLs...")
    results = client.batch_scrape(args.urls)

    # Process results
    for i, result in enumerate(results):
        url = result["url"]
        print(f"\nResults for URL {i+1}: {url}")

        if "error" in result:
            print(f"  Error: {result['error']}")
            continue

        # Print basic info
        print(f"  Status code: {result['status_code']}")
        print(f"  Content length: {len(result.get('content', ''))}")

        # Extract and print metadata
        if "metadata" in result:
            print("\n  Metadata:")
            for key, value in result["metadata"].items():
                print(f"    {key}: {value}")

        # Extract links if requested
        if args.extract_links and "html" in result:
            links = client.extract_links(result["html"], base_url=url)
            print(f"\n  Extracted {len(links)} links:")
            for j, link in enumerate(links[:5]):  # Print first 5 links
                print(f"    {j+1}. {link}")
            if len(links) > 5:
                print(f"    ... and {len(links) - 5} more")

        # Extract images if requested
        if args.extract_images and "html" in result:
            images = client.extract_images(result["html"], base_url=url)
            print(f"\n  Extracted {len(images)} images:")
            for j, image in enumerate(images[:5]):  # Print first 5 images
                print(f"    {j+1}. {image}")
            if len(images) > 5:
                print(f"    ... and {len(images) - 5} more")

            # Download images if requested
            if args.download_images and images:
                images_dir = os.path.join(args.output_dir, f"images_{i+1}")
                os.makedirs(images_dir, exist_ok=True)

                print(f"\n  Downloading {len(images)} images to {images_dir}...")
                for j, image_url in enumerate(images):
                    output_path = os.path.join(images_dir, f"image_{j+1}.jpg")
                    success = client.download_image(image_url, output_path)
                    if success:
                        print(f"    Downloaded: {image_url}")
                    else:
                        print(f"    Failed to download: {image_url}")

    # Save results to files
    save_results(results, args.output_dir)
    print(f"\nSaved results to {args.output_dir}")


if __name__ == "__main__":
    main()
