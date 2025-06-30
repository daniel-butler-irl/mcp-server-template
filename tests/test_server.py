"""Tests for MCP server functionality."""
import asyncio
import json
import os
import sys
from unittest.mock import patch

import pytest

# Add server directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'server'))
import main


class TestMCPServer:
    """Test cases for MCP server functionality."""

    def test_server_initialization(self):
        """Test that server initializes correctly."""
        assert main.mcp is not None
        assert hasattr(main.mcp, 'run')

    @pytest.mark.asyncio
    async def test_hello_tool_basic(self):
        """Test basic hello tool functionality."""
        result = await main.hello("Alice")
        
        assert isinstance(result, str)
        assert "Alice" in result
        assert "MCP Server Tool" in result

    @pytest.mark.asyncio
    async def test_hello_tool_with_environment_vars(self):
        """Test hello tool with environment variable configuration."""
        test_name = "Bob"
        test_prefix = "Custom Greeting"
        
        with patch.dict(os.environ, {
            'MCP_GREETING_PREFIX': test_prefix,
            'MCP_SERVER_NAME': 'Test Server'
        }):
            result = await main.hello(test_name)
            
            assert test_name in result
            assert test_prefix in result

    @pytest.mark.asyncio
    async def test_hello_tool_empty_name(self):
        """Test hello tool with empty name."""
        result = await main.hello("")
        
        assert isinstance(result, str)
        assert len(result) > 0

    @pytest.mark.asyncio
    async def test_hello_tool_special_characters(self):
        """Test hello tool with special characters in name."""
        special_name = "José María"
        result = await main.hello(special_name)
        
        assert special_name in result
        assert isinstance(result, str)

    def test_server_transport_stdio(self):
        """Test that server is configured for stdio transport."""
        # This is more of a smoke test since we can't easily test the actual transport
        # without starting the server
        assert hasattr(main.mcp, 'run')


class TestConfiguration:
    """Test configuration handling."""

    def test_default_configuration(self):
        """Test default configuration values."""
        assert main.mcp is not None
        assert main.SERVER_NAME == "TemplateGreetingMCPServer"