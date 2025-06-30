import time
from datetime import datetime

async def get_server_status() -> dict:
    """Get basic server status information."""
    return {
        "status": "active",
        "timestamp": datetime.now().isoformat(),
        "uptime_seconds": int(time.time()),
        "message": "MCP Server is running and ready to handle requests"
    }