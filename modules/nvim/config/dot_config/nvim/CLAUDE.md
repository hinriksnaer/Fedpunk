# Claude Code - Neovim Environment Context

## Critical: You Are Running Inside Neovim

**You are executing as a terminal buffer INSIDE the Neovim session via claude-code.nvim plugin.**

This means:

1. **You ARE the Neovim session** - Not an external process controlling it
2. **You cannot use MCP Neovim tools** - Tools like `mcp__nvim__navigate`, `mcp__nvim__exec_lua` don't work because you're already inside
3. **`nvim --server` commands don't work** - They will appear in YOUR terminal buffer (where you're running), not control the editor
4. **The `/walkthrough` command is broken** - It assumes you're external to Neovim with MCP tools available

## How to Handle File Edits in Neovim

When the user asks you to edit files or make changes:

1. **Use Read/Write/Edit tools directly** - These work perfectly and are the correct approach
2. **Don't try to automate Neovim commands** - You can't control the editor from inside it
3. **Guide the user through manual edits** - If they want to see changes in their editor, describe what to do

## Window Positioning

- Claude Code opens as a vertical split on the right side
- Starts in normal mode (not terminal mode)
- Configuration: `~/.config/nvim/lua/plugins/claude-code.lua`

## Before Terminal Commands

When running terminal commands that might affect the Neovim session:
- Remember you're IN a terminal buffer
- Normal bash commands work fine
- Just don't try to control Neovim itself with `nvim --server`
