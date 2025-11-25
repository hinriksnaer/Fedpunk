-- Fedpunk theme: catppuccin-latte
-- This file is symlinked to ~/.config/nvim/lua/plugins/theme.lua
-- All theme plugins are defined in colorscheme.lua

-- Return empty table when imported by lazy.nvim (already configured in lazy.lua)
-- Return full spec when read by fedpunk theme system or dev profile theme-watcher
if vim.g.lazyvim_configured then
  return {}
end

return {
  {
    "LazyVim/LazyVim",
    priority = 1000,
    opts = {
      colorscheme = "catppuccin-latte",
    },
  },
}
