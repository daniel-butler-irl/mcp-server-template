# MCP Server Template

> ⚠️ **Work in Progress** ⚠️  
> The DXT format is new and I am still figuring it out. Expect changes and improvements!

A template repository for creating Model Context Protocol (MCP) servers using Python and FastMCP.

## Overview

This template represents **my interpretation** of how to properly build and manage Model Context Protocol (MCP) servers, complete with comprehensive automation and tooling. It provides a ready-to-use foundation that goes beyond basic MCP server creation by including:

- 🔧 **Complete Development Workflow**: Automated build processes, testing, and packaging
- 📦 **Integrated Tooling**: Built-in MCP CLI tools for development and testing
- 🚀 **Production-Ready Structure**: Organized codebase with proper separation of concerns
- ⚡ **Best Practices**: Modern Python packaging, configuration management, and deployment strategies

The Model Context Protocol (MCP) is an open standard that enables AI assistants to securely access external data sources and tools. This template demonstrates what I believe is the right way to structure, develop, test, and deploy MCP servers in a maintainable and scalable manner.

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
python server/main.py
```

The server will start and listen for MCP protocol messages via stdin/stdout.

### Desktop Extension Installation

1. **Build the extension:**
   ```bash
   make pack-dxt
   ```

2. **Install in Claude Desktop:**
   - Open Claude Desktop
   - Go to Settings > Extensions
   - Click "Install Extension" and select the generated `.dxt` file

### Testing with MCP CLI

You can test the server using the MCP CLI tools included in this repository. Here are sample prompts and their expected responses:

#### CLI Commands to Test MCP Server

**List available tools:**
```bash
> /tools
```

**List available resources:**
```bash
> /resources
```

**List available prompts:**
```bash
> /prompts
```

#### Tool Example
**Prompt:** "Hi, I'm Alice"

**Expected Response:**
```
🚀 Greetings from the MCP Server Tool, Alice! This is your unique confirmation that the Model Context Protocol server is actively responding to your request. ✨
```

#### Resource Example  
**Step 1 - Check available resources:**
```bash
> /resources
```

**Step 2 - Ask for server status:**
```bash
> What's the server status?
```

**Expected Response (after updates):**
```
I can access real-time server status information via the server://status resource. To get this information, you can either use the `/resources` command to see available resources, or ask me to 'read the server status resource' and I'll guide you through accessing it.
```

**Step 3 - Request specific resource access:**
```bash
> Please read the server status resource
```

**Expected Response:**
```
[Assistant should guide you through accessing the resource via CLI commands]
```

#### Prompt Example
**Step 1 - Check available prompts:**
```bash
> /prompts
```

**Step 2 - Use the assistant prompt:**
```bash
> Can you use the greeting assistant prompt to explain your capabilities?
```

**Expected Response:**
```
I have access to MCP tools, resources, and prompts. Use `/tools`, `/resources`, and `/prompts` commands to see what's available, then ask me to use specific capabilities.

MCP CAPABILITIES AVAILABLE:
- TOOLS: Functions I can call directly (like 'hello' for greetings)
- RESOURCES: Data I can access (like 'server://status' for server information)  
- PROMPTS: Templates for guidance (like this assistant configuration)
```

#### Direct MCP Protocol Testing

You can also test using raw MCP protocol messages:

**Tool call:**
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

**Resource call:**
```json
{
  "method": "resources/read",
  "params": {
    "uri": "server://status"
  }
}
```

**Prompt call:**
```json
{
  "method": "prompts/get",
  "params": {
    "name": "greeting_assistant"
  }
}
```

## Project Structure

```
mcp-server-template/
├── manifest.json        # Desktop extension configuration
├── icon.png            # Extension icon
├── server/             # MCP server implementation
│   ├── main.py         # Main server entry point
│   ├── tools/          # Tool implementations
│   ├── resources/      # Resource implementations
│   └── prompts/        # Prompt templates
├── pyproject.toml      # Python project configuration
├── .github/workflows/  # CI/CD automation
├── tests/              # Test suite
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

### Desktop Extension Configuration

The extension can be configured through `manifest.json`:

```json
{
  "config": {
    "serverName": {
      "type": "string",
      "title": "Server Name",
      "description": "The display name for this MCP server",
      "default": "Template MCP Server"
    },
    "greetingPrefix": {
      "type": "string", 
      "title": "Greeting Prefix",
      "description": "Custom prefix for greeting messages",
      "default": "🚀 Greetings from the MCP Server Tool"
    }
  }
}
```

### Development Configuration

The server name can be customized by modifying the `FastMCP` initialization in `server/main.py`:

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

### For Desktop Extension Development

1. Clone this template repository
2. Set up development environment: `make setup-dev`
3. Customize the server name and configuration in `manifest.json`
4. Implement your custom tools in `server/main.py` or `server/tools/`
5. Test your extension: `make test-full`
6. Build the extension: `make pack-dxt`
7. Install the `.dxt` file in Claude Desktop

### For Traditional MCP Server Development

1. Clone this template repository
2. Rename the project and update the server name in `server/main.py`
3. Implement your custom tools using the `@mcp.tool()` decorator
4. Test your server with the included MCP CLI tools
5. Deploy your server according to your use case

Happy building! 🚀