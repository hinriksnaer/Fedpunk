# Claude Code Session Memory

## MCP Neovim Integration - Troubleshooting Guide

### Issue: MCP Connection Errors

When using MCP Neovim tools, you may encounter errors like:

```
MCP error -32603: Failed to get working directory: Error sending request 'nvim_execute_lua'
```

### Root Cause

The MCP Neovim server connection can fail or become stale when:
1. The Neovim socket path changes
2. Neovim restarts but the MCP server still references the old connection
3. Multiple Neovim instances are running with different sockets
4. The connection ID becomes invalid

### Current Configuration

- **MCP Config**: `~/.config/claude-code/mcpServers.json`
- **Socket Path**: `/tmp/nvim.sock`
- **Connection ID**: `ac41cd0` (as of 2025-11-17)

### Troubleshooting Steps

#### 1. Check Available Neovim Sockets

```bash
ls -la /tmp/nvim*.sock
```

Common sockets:
- `/tmp/nvim.sock` - Primary socket
- `/tmp/nvim-code.sock` - Secondary socket

#### 2. Verify Which Socket is Active

If you encounter MCP errors, the connection may be pointing to the wrong socket. Check:

```bash
echo $NVIM  # If set, shows current Neovim socket
```

#### 3. Get Fresh Connection

Use this tool to discover and reconnect:

```
mcp__nvim__get_targets
```

This will show:
- Available socket paths
- Active connection IDs
- Which socket to use

#### 4. Update MCP Configuration

If the socket path changed, update `~/.config/claude-code/mcpServers.json`:

```json
{
  "mcpServers": {
    "nvim": {
      "command": "npx",
      "args": [
        "-y",
        "@neovim/mcp-server-neovim",
        "/tmp/nvim.sock"  // Update this path if needed
      ]
    }
  }
}
```

#### 5. Test Connection

After fixing the socket path, test with:

```
mcp__nvim__list_buffers with connection_id: <current_id>
```

### Common Error Patterns

| Error | Likely Cause | Solution |
|-------|--------------|----------|
| `Failed to get working directory` | Stale connection | Reconnect using fresh connection ID |
| `No Neovim targets found` | Wrong socket path or Neovim not running | Check socket paths and update config |
| `Error sending request 'nvim_execute_lua'` | Connection lost | Get new connection via `get_targets` |

### Working with Project-Relative Paths

When using MCP tools with `project_relative_path`, you may need to specify paths relative to where Neovim was launched, not the current `cwd` of Claude Code.

Example:
```
# If Neovim was launched from ~/Documents/pytorch-devcontainers/pytorch
# Use paths relative to that directory
document: {"project_relative_path": "torch/_dynamo/guards.py"}
```

### Alternative: Use Buffer IDs

When project paths fail, use buffer IDs instead:

1. List buffers: `mcp__nvim__list_buffers`
2. Find the buffer ID for your target file
3. Use: `document: {"buffer_id": 27}` instead of paths

This is more reliable when working across different directories.

### When to Use Absolute Paths

If both relative paths and buffer IDs have issues, use absolute paths:

```
document: {"absolute_path": "/home/softmax/Documents/pytorch-devcontainers/pytorch/torch/_dynamo/guards.py"}
```

### Prevention Tips

1. **Consistent socket naming**: Set up Neovim to always use the same socket path
2. **Check connection before operations**: Use `cursor_position` as a quick connection test
3. **Use buffer IDs for open files**: More reliable than paths
4. **Keep MCP config in sync**: Update socket path when changing Neovim setup

### Last Known Good Configuration

- Socket: `/tmp/nvim.sock`
- Connection: `ac41cd0`
- Working directory: `/home/softmax/Documents/pytorch-devcontainers/pytorch`
- Date: 2025-11-17

---

## File Edit That Was Fixed

Fixed Lua operator precedence issue in `config/neovim/.config/nvim/lua/claude-code/window.lua:43`

**Issue**: Missing parentheses caused incorrect evaluation order
**Fix**: Added parentheses around boolean comparison

```lua
-- Before:
local size = config.window.position == "right" or config.window.position == "left"
  and config.window.width
  or config.window.height

-- After:
local size = (config.window.position == "right" or config.window.position == "left")
  and config.window.width
  or config.window.height
```

This ensures the position check is evaluated first before the ternary-style `and/or` operator selects the appropriate dimension.
