# Desktop Extensions (DXT) - Known Issues

## ⚠️ **NOT RECOMMENDED FOR PRODUCTION USE**

Desktop Extensions (.dxt) for Python-based MCP servers currently have significant reliability issues that make them unsuitable for production use.

## Known Issues

### 1. **Python Executable Permissions**
- **Issue**: DXT extraction strips execute permissions from Python binaries
- **Result**: `EACCES: permission denied` errors when trying to run the server
- **Impact**: Extensions fail to start

### 2. **Virtual Environment Path Issues**
- **Issue**: Bundled virtual environments don't work reliably across different systems
- **Result**: Python interpreter not found or dependency issues
- **Impact**: Server fails to launch

### 3. **System Python Compatibility**
- **Issue**: Different macOS/Linux systems have different Python versions and paths
- **Result**: `ENOENT: no such file or directory` errors
- **Impact**: Extensions fail to install or run

### 4. **Signing Functionality**
- **Issue**: DXT signing appears broken in CLI version 0.2.0
- **Result**: Extensions report as "not signed" even after successful signing
- **Impact**: No signature verification possible

### 5. **File System Access**
- **Issue**: Claude Desktop has trouble accessing certain directories within extensions
- **Result**: `ENOENT` errors for `.claude/` directory and other paths
- **Impact**: Configuration and runtime issues

## Current Recommendation

**Use traditional MCP server installation instead:**

1. **Manual Installation**: Follow MCP documentation for manual server setup
2. **Package Managers**: Use pip/uv for dependency management
3. **Configuration**: Use Claude Desktop's `claude_desktop_config.json`

## CI/CD Considerations

**For maintainers**: Do not publish DXT files in automated pipelines until these issues are resolved:

- Avoid including `make pack-dxt` in release workflows
- Do not upload `.dxt` files to releases or package registries
- Focus CI/CD on Python package publishing instead

## Future Development

The DXT implementation is preserved in this template for future use when these issues are resolved by Anthropic. The Makefile targets remain available but are marked as experimental.

### Available Commands (Use with Caution)

```bash
# Build DXT (will show warnings)
make pack-dxt
```

## References

- [Desktop Extensions Documentation](https://github.com/anthropics/dxt)
- [MCP Documentation](https://modelcontextprotocol.io/)
- [Claude Desktop MCP Setup](https://support.anthropic.com/en/articles/10949351-getting-started-with-model-context-protocol-mcp-on-claude-for-desktop)

---

*Last updated: 2025-07-01*
