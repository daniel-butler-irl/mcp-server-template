.PHONY: install setup start stop clean help status pack-dxt setup-dev test-full

# Default target - sets up development environment
.DEFAULT_GOAL := setup-dev

# Configuration variables - override with make VAR=value if needed
MCP_DIR = ./mcp-cli
OLLAMA_MODEL = granite3.3:2b
OLLAMA_MODEL_DISPLAY = Granite 3.3 2B
LLM_PROVIDER = ollama
OLLAMA_SERVE_WAIT = 5
OLLAMA_START_WAIT = 3
CONFIG_FILE = server_config.json
MCP_SERVER_NAME = local-server

help:
	@echo "MCP Server Template with Desktop Extension Support"
	@echo ""
	@echo "Quick Start:"
	@echo "  make         - Setup development environment (recommended first step)"
	@echo ""
	@echo "Configuration:"
	@echo "  Model: $(OLLAMA_MODEL_DISPLAY)"
	@echo "  Provider: $(LLM_PROVIDER)"
	@echo "  MCP Server: $(MCP_SERVER_NAME)"
	@echo "  MCP Directory: $(MCP_DIR)"
	@echo ""
	@echo "Development targets:"
	@echo "  setup-dev    - Install development dependencies and pre-commit hooks"
	@echo "  test-full    - Run all tests including extension validation"
	@echo ""
	@echo "MCP CLI targets:"
	@echo "  install      - Install mcp-cli and dependencies"
	@echo "  setup        - Setup Ollama and pull $(OLLAMA_MODEL_DISPLAY) model"
	@echo "  start        - Start mcp-cli with Ollama and $(OLLAMA_MODEL_DISPLAY)"
	@echo "  stop         - Stop Ollama service"
	@echo "  status       - Show status of Ollama and model"
	@echo "  clean        - Clean up temporary files and directories"
	@echo ""
	@echo "Desktop Extension targets:"
	@echo "  pack-dxt     - Build DXT extension file"
	@echo ""
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Example: make OLLAMA_MODEL=llama3:8b setup"

install:
	@echo "Installing uv if not present..."
	@which uv > /dev/null || (echo "Please install uv first: https://docs.astral.sh/uv/getting-started/installation/" && exit 1)
	@echo "Installing MCP server dependencies..."
	uv sync
	@echo "Cloning mcp-cli..."
	@if [ ! -d "$(MCP_DIR)" ]; then \
		git clone https://github.com/chrishayuk/mcp-cli $(MCP_DIR); \
	fi
	@echo "Creating virtual environment for mcp-cli..."
	cd $(MCP_DIR) && uv venv
	@echo "Installing mcp-cli with uv..."
	cd $(MCP_DIR) && uv pip install -e ".[cli,dev]"
	@echo "Configuring MCP server..."
	@echo "Creating server config for local MCP server..."
	@echo '{' > $(MCP_DIR)/$(CONFIG_FILE)
	@echo '  "mcpServers": {' >> $(MCP_DIR)/$(CONFIG_FILE)
	@echo '    "$(MCP_SERVER_NAME)": {' >> $(MCP_DIR)/$(CONFIG_FILE)
	@echo '      "command": "../.venv/bin/python",' >> $(MCP_DIR)/$(CONFIG_FILE)
	@echo '      "args": ["../server/main.py"],' >> $(MCP_DIR)/$(CONFIG_FILE)
	@echo '      "env": {}' >> $(MCP_DIR)/$(CONFIG_FILE)
	@echo '    }' >> $(MCP_DIR)/$(CONFIG_FILE)
	@echo '  }' >> $(MCP_DIR)/$(CONFIG_FILE)
	@echo '}' >> $(MCP_DIR)/$(CONFIG_FILE)
	@echo "Checking for Ollama installation..."
	@which ollama > /dev/null || (echo "Installing Ollama..." && curl -fsSL https://ollama.ai/install.sh | sh)

setup: install
	@echo "Starting Ollama service..."
	@pgrep ollama > /dev/null || ollama serve &
	@sleep $(OLLAMA_SERVE_WAIT)
	@echo "Pulling $(OLLAMA_MODEL_DISPLAY) model..."
	ollama pull $(OLLAMA_MODEL)

start:
	@echo "Starting Ollama service..."
	@pgrep ollama > /dev/null || ollama serve &
	@sleep $(OLLAMA_START_WAIT)
	@echo "Starting mcp-cli with $(OLLAMA_MODEL_DISPLAY) model and $(MCP_SERVER_NAME) server..."
	@echo "Checking which model name to use..."
	@cd $(MCP_DIR) && source .venv/bin/activate && \
	MODEL_TO_USE="$(OLLAMA_MODEL)"; \
	if mcp-cli models ollama | grep -q "$(OLLAMA_MODEL)"; then \
		echo "Using full model name: $(OLLAMA_MODEL)"; \
	elif mcp-cli models ollama | grep -q "$${OLLAMA_MODEL%%:*}"; then \
		BASE_MODEL=$${OLLAMA_MODEL%%:*}; \
		echo "Full model name not available, using base name: $$BASE_MODEL"; \
		MODEL_TO_USE="$$BASE_MODEL"; \
	else \
		echo "Neither model name available. Available models:"; \
		mcp-cli models ollama; \
		exit 1; \
	fi; \
	echo "Starting with model: $$MODEL_TO_USE"; \
	mcp-cli --provider $(LLM_PROVIDER) --model "$$MODEL_TO_USE" --server $(MCP_SERVER_NAME)

stop:
	@echo "Stopping Ollama service..."
	@pkill ollama || true

status:
	@echo "Ollama Status:"
	@if pgrep ollama > /dev/null; then \
		echo "  Service: Running"; \
	else \
		echo "  Service: Stopped"; \
	fi
	@echo "  Model: $(OLLAMA_MODEL_DISPLAY)"
	@if ollama list | grep -q "$(OLLAMA_MODEL)"; then \
		echo "  Model Status: Downloaded"; \
	else \
		echo "  Model Status: Not downloaded"; \
	fi
	@echo "\nMCP CLI Status:"
	@if [ -d "$(MCP_DIR)" ]; then \
		echo "  Installation: Present"; \
	else \
		echo "  Installation: Missing"; \
	fi
	@if [ -f "$(MCP_DIR)/.venv/bin/activate" ]; then \
		echo "  Virtual Env: Ready"; \
	else \
		echo "  Virtual Env: Missing"; \
	fi

clean:
	@echo "Cleaning up..."
	@rm -rf $(MCP_DIR)
	@rm -f .ollama.log $(CONFIG_FILE)
	@pkill ollama || true
	@echo "Cleanup complete"

# Default target - sets up development environment
all: setup-dev

# Desktop Extension Development Targets
pack-dxt:
	@echo "Building DXT extension..."
	@which node > /dev/null || (echo "Node.js is required to pack DXT extensions" && exit 1)
	@which uv > /dev/null || (echo "uv is required to generate requirements.txt" && exit 1)
	@echo "Removing old DXT files..."
	@rm -f *.dxt
	@echo "Ensuring required files exist..."
	@test -f manifest.json || (echo "manifest.json not found" && exit 1)
	@test -f server/main.py || (echo "server/main.py not found" && exit 1)
	@test -f icon.png || (echo "icon.png not found" && exit 1)
	@echo "Ensuring virtual environment exists..."
	@test -f .venv/bin/python || (echo "Virtual environment not found. Run 'uv sync' first." && exit 1)
	@echo "Generating requirements.txt from uv.lock..."
	uv export --no-hashes --format requirements-txt > requirements.txt
	@echo "Packing DXT extension..."
	npx @anthropic-ai/dxt pack
	@echo "Cleaning up generated files..."
	@rm -f requirements.txt
	@echo "DXT extension built successfully"


setup-dev:
	@echo "Setting up development environment..."
	@which uv > /dev/null || (echo "Please install uv first: https://docs.astral.sh/uv/getting-started/installation/" && exit 1)
	uv sync --dev
	@echo "Installing pre-commit hooks..."
	uv run pre-commit install
	@echo "Development environment setup complete"

test-full:
	@echo "Running comprehensive test suite..."
	@which uv > /dev/null || (echo "Please install uv first and run 'make setup-dev'" && exit 1)
	@echo "Running pytest on tests directory only..."
	uv run pytest tests/
	@echo "All tests passed"
