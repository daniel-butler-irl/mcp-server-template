# MCP Server Template

A template repository for creating Model Context Protocol (MCP) servers using Python and FastMCP.

## Overview

This template provides a ready-to-use foundation for building MCP servers. It includes a simple greeting tool that demonstrates the basic structure and patterns for creating MCP tools and servers.

The Model Context Protocol (MCP) is an open standard that enables AI assistants to securely access external data sources and tools. This template helps you quickly get started with creating your own MCP server.

## Features

- 🚀 **FastMCP Integration**: Built using the FastMCP framework for rapid development
- 🛠️ **Example Tool**: Includes a sample greeting tool to demonstrate MCP tool patterns
- 📦 **Modern Python**: Uses modern Python packaging with `pyproject.toml`
- 🔧 **Easy Setup**: Simple installation and setup process
- 📋 **Standard Transport**: Configured for stdio transport protocol

## Prerequisites

- Python 3.10 or higher
- [uv](https://docs.astral.sh/uv/) package manager (recommended) or pip

## Installation

### Using uv (recommended)

```bash
# Clone the repository
git clone <your-repo-url>
cd mcp-server-template

# Install dependencies
uv sync
```

### Using pip

```bash
# Clone the repository
git clone <your-repo-url>
cd mcp-server-template

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -e .
```

## Usage

### Running the Server

```bash
python main.py
```

The server will start and listen for MCP protocol messages via stdin/stdout.

### Testing the Server

You can test the server using any MCP-compatible client or the MCP CLI tools included in this repository.

Example tool call:
```json
{
  "method": "tools/call",
  "params": {
    "name": "hello",
    "arguments": {
      "name": "Alice"
    }
  }
}
```

Expected response:
```
🚀 Greetings from the MCP Server Tool, Alice! This is your unique confirmation that the Model Context Protocol server is actively responding to your request. ✨
```

## Project Structure

```
mcp-server-template/
├── main.py              # Main MCP server implementation
├── pyproject.toml       # Python project configuration
├── uv.lock             # Dependency lock file
├── LICENSE             # Apache 2.0 license
├── README.md           # This file
├── Makefile           # Build and development commands
└── mcp-cli/           # MCP CLI tools and utilities
```

## Development

### Adding New Tools

To add new tools to your MCP server, follow this pattern:

```python
@mcp.tool()
async def your_tool_name(param1: str, param2: int) -> str:
    """
    Description of your tool.
    
    Args:
        param1: Description of parameter 1
        param2: Description of parameter 2
    
    Returns:
        str: Description of return value
    """
    # Your tool implementation here
    return "result"
```

### Key Considerations

- All tools should be async functions
- Use type hints for parameters and return values
- Provide clear docstrings that explain when and how to use the tool
- Return values should be JSON-serializable
- Handle errors gracefully within your tools

## Configuration

The server name can be customized by modifying the `FastMCP` initialization in `main.py`:

```python
mcp = FastMCP("YourServerName")
```

For more advanced configuration options, refer to the [FastMCP documentation](https://github.com/jlowin/fastmcp).

## MCP CLI Tools

This template includes a comprehensive MCP CLI tool suite in the `mcp-cli/` directory that provides:

- Interactive chat interface with MCP servers
- Server management and configuration
- Tool discovery and testing utilities
- Resource management capabilities
- LLM integration for enhanced workflows

See `mcp-cli/README.md` for detailed documentation on using these tools.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Resources

- [Model Context Protocol Specification](https://spec.modelcontextprotocol.io/)
- [FastMCP Documentation](https://github.com/jlowin/fastmcp)
- [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)

## Getting Started

1. Clone this template repository
2. Rename the project and update the server name in `main.py`
3. Implement your custom tools using the `@mcp.tool()` decorator
4. Test your server with the included MCP CLI tools
5. Deploy your server according to your use case

Happy building! 🚀