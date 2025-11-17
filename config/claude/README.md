# Claude Code Configuration for Fedpunk

This package provides Claude Code integration for Fedpunk installations.

## What Gets Deployed

When you run `fish install.fish`, this package deploys:

### 1. Global MCP Configuration (`~/.mcp.json`)
Configures the Neovim MCP server to connect to `/tmp/nvim.sock`:
```json
{
  "mcpServers": {
    "nvim": {
      "command": "nvim-mcp",
      "args": ["--connect", "/tmp/nvim.sock"]
    }
  }
}
```

### 2. Claude Config (`~/.config/claude/config.json`)
Sets up session hooks:
```json
{
  "hooks": {
    "onSessionStart": "if [ -S /tmp/nvim.sock ]; then echo 'Connect to Neovim at /tmp/nvim.sock'; fi"
  }
}
```

### 3. Claude Commands (`~/.claude/commands/`)
Includes the `/walkthrough` command for interactive code exploration.

## Directory Structure

```
config/claude/
├── .mcp.json                      # Global MCP server config
├── .config/claude/config.json     # Claude Code config
├── .claude/commands/              # Custom slash commands
│   └── walkthrough.md             # Interactive walkthrough command
└── README.md                      # This file
```

## Manual Installation

If you want to deploy just the Claude Code config:

```bash
cd ~/.local/share/fedpunk/config
stow -v -t ~ claude
```

## Uninstallation

To remove the Claude Code configuration:

```bash
cd ~/.local/share/fedpunk/config
stow -D -t ~ claude
```

## Prerequisites

- Claude Code CLI installed
- `nvim-mcp` installed (via cargo: `cargo install nvim-mcp`)
- Neovim configured with socket at `/tmp/nvim.sock`

## Integration with Neovim

The Neovim CLAUDE.md documentation is deployed separately via the `neovim` config package.
See `~/.config/nvim/CLAUDE.md` for usage notes when running Claude Code inside Neovim.

## Customization

To add your own Claude commands:
1. Create markdown files in `.claude/commands/`
2. Each file becomes a slash command (e.g., `mycommand.md` → `/mycommand`)
3. Run `stow -R -t ~ claude` to redeploy

For more info: https://code.claude.com/docs
