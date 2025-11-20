# claude-code.nvim

A Neovim plugin for seamless Claude Code integration within Fedpunk.

## Features

- 🪟 **Window Management** - Smart split positioning and buffer handling
- ⌨️ **Keybindings** - Quick access with leader key combinations
- 🔧 **Commands** - User commands for all operations
- 🎯 **Auto-Exit Terminal Mode** - Starts in normal mode for easy navigation
- 📦 **Buffer Management** - Close multiple buffers easily
- 🎨 **Fedpunk Integration** - Seamlessly integrated into the Fedpunk workflow

## Installation

This plugin is automatically installed with Fedpunk. No manual installation needed!

It's configured in `~/.config/nvim/lua/plugins/claude-code.lua` using LazyVim.

## Commands

| Command | Description |
|---------|-------------|
| `:ClaudeCode` | Open Claude Code in a split |
| `:ClaudeToggle` | Toggle Claude Code window |
| `:ClaudeClose` | Close Claude Code window |
| `:ClaudeFocus` | Focus Claude Code window |
| `:ClaudeExitTerminal` | Exit terminal mode |
| `:ClaudeCloseBuffers 1 2 3` | Close buffers by number |
| `:ClaudeBuffers` | List all open buffers |
| `:ClaudeAsk [question]` | Send buffer/selection to Claude |

## Keybindings

Default keybindings (all use `<leader>c` prefix):

| Key | Command | Description |
|-----|---------|-------------|
| `<leader>cc` | `:ClaudeToggle` | Toggle Claude Code |
| `<leader>cq` | `:ClaudeClose` | Close Claude Code |
| `<leader>cf` | `:ClaudeFocus` | Focus Claude Code |
| `<leader>ca` | `:ClaudeAsk` | Ask about buffer/selection |
| `<leader>ce` | `:ClaudeExitTerminal` | Exit terminal mode |
| `<leader>cb` | `:ClaudeBuffers` | List buffers |

## Configuration

Edit `~/.config/nvim/lua/plugins/claude-code.lua` to customize:

```lua
opts = {
  window = {
    position = "right",  -- "left", "right", "top", "bottom"
    width = 80,          -- Width in columns
    height = 20,         -- Height in rows
    border = "rounded",  -- "none", "single", "double", "rounded"
  },

  terminal = {
    shell = "claude",              -- Command to run
    start_in_normal_mode = true,   -- Start in normal mode
  },

  keymaps = {
    toggle = "<leader>cc",
    close = "<leader>cq",
    focus = "<leader>cf",
    ask = "<leader>ca",
  },

  auto_commands = {
    close_with_q = true,           -- Press 'q' to close
    exit_terminal_mode = true,     -- Auto-exit terminal mode
  },

  integration = {
    notify = true,                  -- Use vim.notify
  },
}
```

## Usage Examples

### Basic Workflow

1. **Open Claude**: `<leader>cc` or `:ClaudeCode`
2. **Ask a question**: Type your question in Claude
3. **Exit terminal mode**: `<C-\><C-n>` or `<leader>ce`
4. **Navigate**: Use normal Vim navigation
5. **Close**: `q` or `<leader>cq`

### Ask About Code

1. Select code in visual mode
2. Press `<leader>ca`
3. Claude opens with the selection ready for questions

### Clean Up Buffers

```vim
:ClaudeBuffers           " See what's open
:ClaudeCloseBuffers 2 5 7   " Close buffers 2, 5, and 7
```

## Architecture

```
lua/claude-code/
├── init.lua       # Main module & setup
├── config.lua     # Configuration management
├── window.lua     # Window/buffer operations
├── commands.lua   # User command definitions
└── README.md      # This file
```

## How It Works

1. **LazyVim loads** the plugin on startup
2. **Plugin creates** user commands and keybindings
3. **When opened**, creates a terminal buffer running `claude`
4. **Window management** handles positioning and state
5. **Commands provide** easy access to all features

## Advanced Usage

### Programmatic Access

```lua
local claude = require("claude-code")

-- Open Claude
claude.window.open(claude.config.get())

-- Close specific buffers
claude.window.close_buffers({1, 2, 3})

-- Get buffer list
local buffers = claude.window.get_buffers()
for _, buf in ipairs(buffers) do
  print(buf.number, buf.name)
end
```

### Custom Commands

Add your own commands in `~/.config/nvim/lua/config/autocmds.lua`:

```lua
vim.api.nvim_create_user_command("MyClaudeCommand", function()
  require("claude-code").window.open(require("claude-code").config.get())
  -- Your custom logic here
end, {})
```

## Troubleshooting

### Claude doesn't open
- Ensure `claude` CLI is installed and in PATH
- Check `:messages` for errors

### Terminal mode issues
- Use `<C-\><C-n>` to exit terminal mode
- Or use `:ClaudeExitTerminal` / `<leader>ce`

### Keybindings don't work
- Check for conflicts with `:verbose map <leader>cc`
- Customize keybindings in plugin config

## Contributing

This plugin is part of Fedpunk. To contribute:

1. Edit files in `~/.local/share/fedpunk/config/neovim/.config/nvim/lua/claude-code/`
2. Test your changes
3. Submit a PR to the Fedpunk repository

## License

Part of Fedpunk - MIT License
