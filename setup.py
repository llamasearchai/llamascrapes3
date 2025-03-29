#!/usr/bin/env python3
"""
ElysianLens setup script.

This script configures the installation of the ElysianLens package,
including dependencies, entry points, and package metadata.
"""

import os
from setuptools import setup, find_packages

# Read the contents of README.md
with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

# Define package requirements
requirements = [
    "typer>=0.9.0",
    "rich>=13.4.2",
    "requests>=2.31.0",
    "beautifulsoup4>=4.12.2",
    "playwright>=1.40.0",
    "numpy>=1.24.0",
    "pandas>=2.0.0",
    "pydantic>=2.4.0",
]

# Optional dependencies
extras_require = {
    # MLX dependencies (Apple Silicon only)
    "mlx": [
        "mlx>=0.3.0",
        "mlx-lm>=0.0.10",
        "transformers>=4.35.0",
    ],
    # MLX-TextGen integration
    "textgen": [
        "mlx-textgen>=0.1.0",
    ],
    # Development dependencies
    "dev": [
        "pytest>=7.3.1",
        "pytest-cov>=4.1.0",
        "black>=23.3.0",
        "isort>=5.12.0",
        "mypy>=1.3.0",
        "flake8>=6.0.0",
        "sphinx>=7.0.0",
        "sphinx-rtd-theme>=1.2.2",
    ],
    # Documentation dependencies
    "docs": [
        "sphinx>=7.0.0",
        "sphinx-rtd-theme>=1.2.2",
        "sphinx-autodoc-typehints>=1.23.0",
        "myst-parser>=2.0.0",
    ],
    # Integration dependencies
    "integrations": [
        "shot-scraper>=1.2.0",
        "datasette>=0.64.3",
        "finance-scrapers>=0.1.0",
        "llama-index-mlx>=0.1.0",
    ],
}

# All dependencies
extras_require["all"] = sorted(set(sum(extras_require.values(), [])))

setup(
    name="elysian-lens-llamasearch",
    version="0.1.0",
    author="LlamaSearch AI",
    author_email="nikjois@llamasearch.ai",
    description="Advanced Web Scraping & AI-Enhanced Data Analysis",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://llamasearch.ai",
    project_urls={
        "Bug Tracker": "https://github.com/elysianlens/elysian-lens/issues",
        "Documentation": "https://elysian-lens.readthedocs.io/",
        "Source Code": "https://github.com/elysianlens/elysian-lens",
    },
    packages=find_packages(),
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Topic :: Internet :: WWW/HTTP :: Browsers",
        "Topic :: Internet :: WWW/HTTP :: Indexing/Search",
        "Topic :: Scientific/Engineering :: Artificial Intelligence",
        "Topic :: Software Development :: Libraries :: Python Modules",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.9",
    install_requires=requirements,
    extras_require=extras_require,
    entry_points={
        "console_scripts": [
            "elysian-lens=elysian_lens.__main__:main",
        ],
    },
    include_package_data=True,
    zip_safe=False,
    package_dir={"": "src"},
    packages=find_packages(where="src"),
) 
# Updated in commit 5 - 2025-04-04 17:44:48

# Updated in commit 13 - 2025-04-04 17:44:49

# Updated in commit 21 - 2025-04-04 17:44:49

# Updated in commit 29 - 2025-04-04 17:44:50

# Updated in commit 5 - 2025-04-05 14:44:05

# Updated in commit 13 - 2025-04-05 14:44:05

# Updated in commit 21 - 2025-04-05 14:44:05

# Updated in commit 29 - 2025-04-05 14:44:05
