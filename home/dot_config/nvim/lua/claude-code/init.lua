-- Main module for claude-code.nvim
local M = {}

local config = require("claude-code.config")
local window = require("claude-code.window")
local commands = require("claude-code.commands")

-- Setup function
function M.setup(opts)
  -- Merge user config with defaults
  config.setup(opts)
  local cfg = config.get()

  -- Create user commands
  commands.setup()

  -- Set up keymaps if configured
  if cfg.keymaps.toggle then
    vim.keymap.set("n", cfg.keymaps.toggle, ":ClaudeToggle<CR>", {
      silent = true,
      desc = "Toggle Claude Code",
    })
  end

  if cfg.keymaps.close then
    vim.keymap.set("n", cfg.keymaps.close, ":ClaudeClose<CR>", {
      silent = true,
      desc = "Close Claude Code",
    })
  end

  if cfg.keymaps.focus then
    vim.keymap.set("n", cfg.keymaps.focus, ":ClaudeFocus<CR>", {
      silent = true,
      desc = "Focus Claude Code",
    })
  end

  if cfg.keymaps.ask then
    vim.keymap.set({ "n", "v" }, cfg.keymaps.ask, ":ClaudeAsk<CR>", {
      silent = true,
      desc = "Ask Claude about buffer/selection",
    })
  end

  -- Notification
  if cfg.integration.notify then
    vim.notify("claude-code.nvim loaded", vim.log.levels.INFO)
  end
end

-- Export window functions for advanced usage
M.window = window
M.config = config

return M
