# Contributing to Elysian Lens

Thank you for your interest in contributing to Elysian Lens! This document provides guidelines and instructions for contributing to this project.

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

## How Can I Contribute?

### Reporting Bugs

This section guides you through submitting a bug report. Following these guidelines helps maintainers understand your report, reproduce the behavior, and find related reports.

**Before Submitting A Bug Report:**

* Check the [issues](https://github.com/elysian-lens/elysian-lens/issues) to see if the problem has already been reported.
* Perform a cursory search to see if the problem has been reported already.

**How Do I Submit A (Good) Bug Report?**

Bugs are tracked as [GitHub issues](https://github.com/elysian-lens/elysian-lens/issues). Create an issue and provide the following information:

* **Use a clear and descriptive title** for the issue to identify the problem.
* **Describe the exact steps which reproduce the problem** in as many details as possible.
* **Provide specific examples to demonstrate the steps**.
* **Describe the behavior you observed after following the steps** and point out what exactly is the problem with that behavior.
* **Explain which behavior you expected to see instead and why.**
* **Include screenshots or animated GIFs** which show you following the described steps and clearly demonstrate the problem.
* **If the problem wasn't triggered by a specific action**, describe what you were doing before the problem happened.

### Suggesting Enhancements

This section guides you through submitting an enhancement suggestion, including completely new features and minor improvements to existing functionality.

**Before Submitting An Enhancement Suggestion:**

* Check the [issues](https://github.com/elysian-lens/elysian-lens/issues) to see if the enhancement has already been suggested.
* Perform a cursory search to see if the enhancement has been suggested before.

**How Do I Submit A (Good) Enhancement Suggestion?**

Enhancement suggestions are tracked as [GitHub issues](https://github.com/elysian-lens/elysian-lens/issues). Create an issue and provide the following information:

* **Use a clear and descriptive title** for the issue to identify the suggestion.
* **Provide a step-by-step description of the suggested enhancement** in as many details as possible.
* **Provide specific examples to demonstrate the steps**.
* **Describe the current behavior** and **explain which behavior you expected to see instead** and why.
* **Explain why this enhancement would be useful** to most Elysian Lens users.

### Pull Requests

* Fill in the required template
* Do not include issue numbers in the PR title
* Follow the [Python style guide](#styleguides)
* Include appropriate tests
* Document new code based on the [Documentation Styleguide](#documentation-styleguide)
* End all files with a newline

## Styleguides

### Git Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line
* When only changing documentation, include `[ci skip]` in the commit title

### Python Styleguide

* Follow [PEP 8](https://www.python.org/dev/peps/pep-0008/)
* Use [Black](https://black.readthedocs.io/) for code formatting
* Use [isort](https://pycqa.github.io/isort/) for import sorting
* Use [flake8](https://flake8.pycqa.org/) for linting

### Documentation Styleguide

* Use [Google-style docstrings](https://google.github.io/styleguide/pyguide.html#38-comments-and-docstrings)
* Use [Markdown](https://guides.github.com/features/mastering-markdown/) for documentation files
* Reference package and module names, function names, class names, method names, variable names, and attributes in backticks: ``

## Development Process

### Setting Up Development Environment

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/elysian-lens.git`
3. Add the original repository as upstream: `git remote add upstream https://github.com/elysian-lens/elysian-lens.git`
4. Create a virtual environment: `python -m venv venv`
5. Activate the virtual environment:
   * Windows: `venv\Scripts\activate`
   * Mac/Linux: `source venv/bin/activate`
6. Install development dependencies: `pip install -e '.[dev]'`

### Development Workflow

1. Create a new branch: `git checkout -b feature/your-feature-name`
2. Make your changes
3. Run tests: `pytest`
4. Format your code: `black .` and `isort .`
5. Lint your code: `flake8`
6. Commit your changes: `git commit -m "Add your feature"`
7. Push to your fork: `git push origin feature/your-feature-name`
8. Create a pull request

### Running Tests

```bash
# Run all tests
pytest

# Run a specific test file
pytest tests/test_specific.py

# Run tests with coverage report
pytest --cov=elysian_lens
```

## Additional Resources

* [GitHub Help](https://help.github.com)
* [Python Documentation](https://docs.python.org/3/)
* [MLX Documentation](https://ml-explore.github.io/mlx/build/html/index.html)

Thank you for contributing to Elysian Lens! 