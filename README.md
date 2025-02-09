# LlamaScrapeS3 🕸️

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python Version](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org/downloads/)
<!-- Add build status, coverage badges -->

**Advanced Web Scraping & Cloud Storage Integration**

`LlamaScrapeS3` is a powerful Python framework designed for efficient and scalable web scraping with seamless integration for storing results directly in Amazon S3 buckets. It provides a robust toolkit for extracting data from the web and managing it in the cloud.

*(Note: This README previously referenced MLX/AI features under the name "ElysianLens". These have been kept for context but may need verification based on the actual code in this specific project.)*

## Key Features ✨

*   **Advanced Web Scraping**: Robust scraping engine with potential multi-engine support and stealth capabilities.
*   **Direct S3 Integration**: Easily configure and save scraped data (HTML, text, screenshots, etc.) to S3.
*   **Scalable Architecture**: Designed to handle large-scale scraping tasks.
*   **(Potentially) MLX-Powered AI Analysis**: May leverage Apple Silicon for fast, efficient AI processing of scraped data (Needs verification).
*   **(Potentially) Function Calling**: May include an intelligent agent architecture (Needs verification).
*   **Rich CLI Interface**: Potentially offers beautiful terminal output with Typer and Rich.
*   **Modular Design**: Easily extensible with custom scraping modules and S3 configurations.

## Architecture Concept 🏗️

```mermaid
graph TD
    A[CLI / Python API] --> B{Scraping Coordinator};
    B --> C[Scraping Engine];
    C --> D[Target Websites];
    B --> E[Data Processor];
    E --> F{AI Analysis (Optional)};
    E --> G[S3 Uploader];
    G --> H[(Amazon S3 Bucket)];

    style G fill:#ffc,stroke:#333,stroke-width:2px
```
*Diagram shows the flow from initiating a scrape via CLI/API, through the engine and processor, optionally to AI analysis, and finally uploading results to S3.*

## Installation 💻

### Prerequisites

*   Python 3.9+
*   AWS Credentials configured (e.g., via environment variables `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION` or IAM role).
*   `boto3` library (`pip install boto3`).

### Steps

1.  **Clone the repository:**
    ```bash
    git clone https://llamasearch.ai # Update URL
    cd llamascrapes3
    ```

2.  **Create a virtual environment (Recommended):**
    ```bash
    python -m venv .venv
    source .venv/bin/activate # On Windows: .venv\Scripts\activate
    ```

3.  **Install dependencies:**
    ```bash
    # Ensure requirements.txt exists and is complete
    pip install -r requirements.txt 
    pip install -e . # Install llamascrapes3 in editable mode
    
    # Optional dependencies (Verify if needed)
    # pip install -e ".[mlx]" # For MLX features
    # pip install -e ".[all]" # For all optional features
    ```

## Configuration

*   **AWS Credentials**: Ensure your AWS credentials are configured correctly for `boto3`.
*   **Project Configuration**: Check for any project-specific configuration files (e.g., `config.toml`) to set S3 bucket names, regions, or scraping parameters.

## Quick Start 🚀

### Command Line Interface (Example)

*(Verify actual CLI commands)*
```bash
# Scrape a website and save results to the default S3 bucket
llamascrapes3 scrape https://example.com --save-s3 --s3-bucket your-bucket-name

# Scrape with depth and save screenshots to S3
llamascrapes3 scrape https://example.com --depth 2 --screenshots --save-s3 --s3-path scraped-data/example.com
```

### Python API (Example)

*(Verify actual API usage)*
```python
from llamascrapes3.scraper import WebScraper # Adjust import based on actual structure
from llamascrapes3.storage import S3Storage

# Configure S3 storage
s3_storage = S3Storage(bucket_name='your-bucket-name', region='us-east-1')

# Initialize scraper with S3 storage
scraper = WebScraper(storage_backend=s3_storage)

# Scrape a website
# The storage backend should handle saving results automatically
scrape_results = scraper.scrape("https://example.com", depth=1)

if scrape_results:
    print(f"Scraping complete. Data saved to S3 bucket: {s3_storage.bucket_name}")
    # Access results if needed
    # print(scrape_results["text"])
else:
    print("Scraping failed.")

```

## Documentation 📚

*   Check the `docs/` directory for detailed documentation.
*   Use `llamascrapes3 --help` or `llamascrapes3 [command] --help` for CLI details.
*   Explore Python docstrings using `help()`.

## Testing 🧪

*(Verify testing commands)*
```bash
# Ensure testing dependencies are installed (e.g., pytest, moto for S3 mocking)
pip install pytest moto

# Run tests (adjust command as needed)
pytest
```

## Contributing 🤝

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on contributing securely and effectively.

## License 📄

Licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support & Community 💬

*   **Issues**: [GitHub Issues](https://llamasearch.ai *(Update link)*
*   **Discord**: [Community Discord](https://discord.gg/llamasearch) *(Update link)*

---

*Part of the LlamaSearchAI Ecosystem - Scalable Web Scraping with Cloud Integration.* 
# Updated in commit 1 - 2025-04-04 17:44:48

# Updated in commit 9 - 2025-04-04 17:44:48

# Updated in commit 17 - 2025-04-04 17:44:49
