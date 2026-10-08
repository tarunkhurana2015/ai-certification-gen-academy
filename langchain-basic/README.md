## 🚀 Setup

### Prerequisites

- The [Chrome](https://www.google.com/chrome/) browser is recommended
- [git](https://git-scm.com/install/) is recommended
- [uv](https://docs.astral.sh/uv/) package manager (includes `uvx`, required by notebook 5)
- The course requires Python >=3.11, <3.14. `uv` will take care of this for you.

### Installation

If setting up this project from scratch, initialize it from the `langchain-basic`
directory with the supported Python range:

```bash
uv init --bare --python ">=3.11,<3.14"
```

Install the dependencies declared in `pyproject.toml` and create the project
virtual environment:

```bash
uv sync
```

To see the installed dependency tree, run:

```bash
uv tree
```

The project supports Python `>=3.11, <3.14`; `uv` selects a compatible version.

### Adding or updating dependencies

The course dependencies are listed in `pyproject.toml`. To add or update them
with `uv`, run this from the `langchain-basic` directory:

```bash
uv add \
  "langgraph>=1.0.0" \
  "langchain>=1.3.10" \
  "langchain-core>=1.4.0" \
  "langchain-openai>=1.1.14" \
  "langchain-anthropic>=1.4.6" \
  "sqlalchemy>=2.0" \
  "jupyter>=1.0.0" \
  "langgraph-cli[inmem]>=0.4.0" \
  "langchain-mcp-adapters" \
  "python-dotenv>=1.2.2"
```

`uv add` updates `pyproject.toml` and `uv.lock`, then installs the dependencies.
For normal setup or after pulling dependency changes, use `uv sync`.

### API keys

Create a `.env` file in this directory. An OpenAI API key is required for the
course examples; LangSmith tracing is optional.

```dotenv
OPENAI_API_KEY=your_openai_api_key_here

# Optional: uncomment and set these values to enable LangSmith tracing.
# LANGSMITH_API_KEY=your_langsmith_api_key_here
# LANGSMITH_TRACING=true
# LANGSMITH_PROJECT=langchain-py-essentials

# Optional: set this for the LangSmith EU instance.
# LANGSMITH_ENDPOINT=https://eu.api.smith.langchain.com

# The examples use OpenAI by default. If you choose Anthropic, configure its
# API key and update the relevant model calls.
# ANTHROPIC_API_KEY=your_anthropic_api_key_here
```
