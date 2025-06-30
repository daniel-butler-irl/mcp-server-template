.PHONY: install setup start stop clean help status

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
	@echo "MCP CLI with Ollama Setup"
	@echo "Configuration:"
	@echo "  Model: $(OLLAMA_MODEL_DISPLAY)"
	@echo "  Provider: $(LLM_PROVIDER)"
	@echo "  MCP Server: $(MCP_SERVER_NAME)"
	@echo "  MCP Directory: $(MCP_DIR)"
	@echo ""
	@echo "Available targets:"
	@echo "  install    - Install mcp-cli and dependencies"
	@echo "  setup      - Setup Ollama and pull $(OLLAMA_MODEL_DISPLAY) model"
	@echo "  start      - Start mcp-cli with Ollama and $(OLLAMA_MODEL_DISPLAY)"
	@echo "  stop       - Stop Ollama service"
	@echo "  status     - Show status of Ollama and model"
	@echo "  clean      - Clean up temporary files and directories"
	@echo "  help       - Show this help message"
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
	@echo '      "args": ["../main.py"],' >> $(MCP_DIR)/$(CONFIG_FILE)
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
	cd $(MCP_DIR) && source .venv/bin/activate && mcp-cli --provider $(LLM_PROVIDER) --model $(OLLAMA_MODEL) --server $(MCP_SERVER_NAME)

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

all: setup start