from mcp.server.fastmcp import FastMCP

mcp = FastMCP("TemplateGreetingMCPServer")


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
    return f"🚀 Greetings from the MCP Server Tool, {name}! This is your unique confirmation that the Model Context Protocol server is actively responding to your request. ✨"


if __name__ == "__main__":
    mcp.run(transport="stdio")
