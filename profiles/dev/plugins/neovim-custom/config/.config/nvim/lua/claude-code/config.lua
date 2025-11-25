-- Configuration module for claude-code.nvim
local M = {}

-- Default configuration
M.defaults = {
  -- Window settings
  window = {
    position = "right", -- "left", "right", "top", "bottom"
    width = 80, -- Width in columns (for vertical splits)
    height = 20, -- Height in rows (for horizontal splits)
    border = "rounded", -- "none", "single", "double", "rounded", "solid", "shadow"
  },

  -- Terminal settings
  terminal = {
    shell = "claude", -- Command to run
    start_in_normal_mode = true, -- Start in normal mode instead of terminal mode
  },

  -- Keymaps
  keymaps = {
    toggle = "<leader>cc", -- Toggle Claude Code window
    close = "<leader>cq", -- Close Claude Code window
    focus = "<leader>cf", -- Focus Claude Code window
    send_buffer = "<leader>cs", -- Send current buffer to Claude
    ask = "<leader>ca", -- Ask about selection/buffer
  },

  -- Commands
  commands = {
    enabled = true,
    prefix = "Claude", -- Commands will be :Claude*, :ClaudeToggle, etc.
  },

  -- Auto commands
  auto_commands = {
    close_with_q = true, -- Close window with 'q' in normal mode
    exit_terminal_mode = true, -- Auto-exit terminal mode when opening
  },

  -- Integration
  integration = {
    notify = true, -- Use vim.notify for messages
  },
}

-- Current configuration (will be merged with defaults)
M.options = {}

-- Setup function
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
  return M.options
end

-- Get current configuration
function M.get()
  return M.options
end

return M
