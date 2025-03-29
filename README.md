# ElysianLens

![ElysianLens Logo](https://raw.githubusercontent.com/elysianlens/elysian-lens/main/docs/images/logo.png)

**Advanced Web Scraping & AI-Enhanced Data Analysis**

ElysianLens is a powerful Python framework that combines advanced web scraping capabilities with state-of-the-art AI analysis powered by MLX on Apple Silicon. It provides a comprehensive toolkit for extracting, processing, and analyzing web data with unprecedented efficiency and intelligence.

[![Python Version](https://img.shields.io/badge/python-3.9%2B-blue)](https://www.python.org/downloads/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![MLX Support](https://img.shields.io/badge/MLX-optimized-orange)](https://github.com/ml-explore/mlx)

## 🌟 Features

- **Advanced Web Scraping**: Multi-engine support with stealth capabilities
- **MLX-Powered AI Analysis**: Leverage Apple Silicon for fast, efficient AI processing
- **Function Calling**: Intelligent agent architecture with function calling support
- **Rich CLI Interface**: Beautiful terminal output with Typer and Rich
- **Modular Design**: Easily extensible with plugins and integrations
- **Third-Party Integrations**: Works with popular tools like shot-scraper, finance-scrapers, and more

## 🚀 Quick Installation

### One-Command Setup (macOS & Linux)

```bash
git clone https://github.com/elysianlens/elysian-lens.git
cd elysian-lens
./setup_elysian_lens.sh
```

The setup script will:
1. Check system requirements
2. Create a virtual environment
3. Install all dependencies
4. Download required MLX models (Apple Silicon only)
5. Run basic tests
6. Configure the system

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/elysianlens/elysian-lens.git
cd elysian-lens

# Create a virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install dependencies
pip install -e .  # Basic installation

# For Apple Silicon Macs with MLX support
pip install -e ".[mlx]"

# For all optional dependencies
pip install -e ".[all]"
```

### MLX Model Download (Apple Silicon only)

```bash
# Download required MLX models
./download_mlx_models.py --all
```

## 🧠 Quick Start

### Command Line Interface

ElysianLens provides a powerful CLI for common tasks:

```bash
# Scrape a website
elysian-lens scrape https://example.com --depth 2 --screenshots

# Analyze content
elysian-lens analyze document.txt --type sentiment

# Generate text with MLX (Apple Silicon only)
elysian-lens generate-text "Write a summary of quantum computing" --model llama3

# Use the agent to perform complex tasks
elysian-lens agent "Find the latest news about Apple and summarize the top 3 articles"

# Start interactive mode
elysian-lens interactive
```

### Python API

```python
from elysian_lens.scraper import WebScraper
from elysian_lens.analyzer import ContentAnalyzer
from elysian_lens.agent import Agent
from elysian_lens.mlx_utils import MLXTextGenerator

# Scrape a website
scraper = WebScraper(headless=True, stealth=True)
result = scraper.scrape("https://example.com", depth=2)

# Analyze content
analyzer = ContentAnalyzer()
sentiment = analyzer.analyze_sentiment(result["text"])

# Generate text with MLX (Apple Silicon only)
generator = MLXTextGenerator(model_name="llama3")
response = generator.generate("Explain quantum computing in simple terms")

# Use the agent architecture
llm = MLXTextGenerator(model_name="llama3")
agent = Agent(llm_provider=llm)

# Register functions the agent can call
from elysian_lens import tools
agent.create_tools_from_module(tools)

# Run the agent
result = agent.run(
    user_input="Find the latest news about Apple and summarize the top 3 articles",
    system_prompt="You are a helpful assistant that finds and summarizes news articles."
)
print(result["response"])
```

## 🧩 MLX Integration (Apple Silicon)

ElysianLens is optimized for Apple Silicon through MLX integration, providing:

- **Fast Text Generation**: Generate text with Llama 3, Mistral, Phi-3, and other models
- **Function Calling**: Enable models to call Python functions based on natural language
- **Embeddings**: Generate embeddings for semantic search and similarity analysis
- **Vision-Language Models**: Process images with multimodal models

### Available MLX Models

ElysianLens supports the following MLX-optimized models:

- **Text Generation**:
  - Llama 3-8B-Instruct
  - Mistral-7B-Instruct-v0.3
  - Phi-3-mini-4k-instruct

- **Embeddings**:
  - E5-small-v2
  - BGE-small-en-v1.5

- **Vision-Language**:
  - LLaVA-7B
  - Phi-3-vision-128k-instruct

## 📚 Documentation

For detailed documentation:

1. **CLI Commands**: Run `elysian-lens --help` or `elysian-lens [command] --help`
2. **Python API**: Use the built-in docstrings (`help(ElysianLens)`)
3. **Online Docs**: Visit [https://elysian-lens.readthedocs.io/](https://elysian-lens.readthedocs.io/)

## 🧪 Testing

Run the included test suite to verify your installation:

```bash
# Run all tests
python test_elysian_lens.py

# Run specific test
python test_elysian_lens.py --test scraper
python test_elysian_lens.py --test analyzer
python test_elysian_lens.py --test mlx  # Apple Silicon only
```

## 🛠️ System Requirements

- Python 3.9+
- For MLX features: Apple Silicon Mac (M1/M2/M3)
- 4GB+ RAM (8GB+ recommended for MLX models)
- Internet connection for web scraping

## 📦 Optional Dependencies

- **MLX**: For Apple Silicon optimized AI (`pip install mlx`)
- **MLX-LM**: For text generation (`pip install mlx-lm`)
- **Playwright**: For advanced web scraping (`pip install playwright`)
- **Shot-Scraper**: For screenshot capabilities (`pip install shot-scraper`)
- **LlamaIndex**: For document indexing and retrieval (`pip install llama-index`)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgements

- [MLX](https://github.com/ml-explore/mlx) by Apple for the amazing ML framework for Apple Silicon
- [Playwright](https://playwright.dev/) for the powerful web automation capabilities
- [Rich](https://github.com/Textualize/rich) for beautiful terminal output
- [Typer](https://typer.tiangolo.com/) for the CLI interface
- [LlamaIndex](https://www.llamaindex.ai/) for document indexing capabilities 