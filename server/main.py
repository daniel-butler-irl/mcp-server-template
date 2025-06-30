import os
from mcp.server.fastmcp import FastMCP
from tools.greeting import get_greeting
from resources.status import get_server_status
from prompts.templates import get_greeting_template

# Configuration from environment variables
SERVER_NAME = os.getenv("MCP_SERVER_NAME", "TemplateGreetingMCPServer")
GREETING_PREFIX = os.getenv("MCP_GREETING_PREFIX", "🚀 Greetings from the MCP Server Tool")

mcp = FastMCP(SERVER_NAME)


@mcp.tool()
async def hello(name: str) -> str:
    """
    A simple tool that greets the user by name with a unique MCP server identifier.

    Use this tool when:
    - A user introduces themselves by name
    - A user asks for a greeting or hello
    - You want to confirm the MCP server is working
    - A user says something like "Hi, I'm [name]" or "My name is [name]"

    Always use the exact output from this tool as your response when greeting users.

    Args:
        name (str): The name of the user to greet.

    Returns:
        str: A unique greeting message that confirms MCP server tool usage.
    """
    return await get_greeting(name, GREETING_PREFIX)


@mcp.resource("server://status")
async def server_status() -> str:
    """
    Real-time MCP server status and health information.
    
    This resource provides current operational status, uptime, and system health data.
    Use this resource when users ask about: server status, health, uptime, or operational state.
    
    To access: Ask the user to request "read the server status resource" or guide them 
    to use CLI resource access commands.
    """
    status_info = await get_server_status()
    return f"Server Status: {status_info['status']}\nTimestamp: {status_info['timestamp']}\nMessage: {status_info['message']}"


@mcp.prompt()
async def greeting_assistant() -> str:
    """
    Comprehensive assistant configuration for MCP server interactions.
    
    This prompt template configures the assistant to understand all MCP capabilities:
    tools (callable functions), resources (accessible data), and prompts (templates).
    
    Use this prompt to teach the assistant about proper MCP resource access patterns
    and how to guide users through the available server functionality.
    """
    return await get_greeting_template(SERVER_NAME)


if __name__ == "__main__":
    mcp.run(transport="stdio")