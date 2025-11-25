-- Fedpunk theme: rose-pine-dark
-- This file is symlinked to ~/.config/nvim/lua/plugins/theme.lua

-- Return empty table when imported by lazy.nvim (already configured in lazy.lua)
-- Return full spec when read by fedpunk theme system or dev profile theme-watcher
if vim.g.lazyvim_configured then
  return {}
end

return {
	{
		"rose-pine/neovim",
		name = "rose-pine",
		-- Customize theme specs, e.g: disable italic. For full spec: https://github.com/rose-pine/neovim
		-- config = function()
		-- require("rose-pine").setup({
		--  styles = {
		--    italic = false,
		--  },
		-- })
		-- end,
	},
	{
		"LazyVim/LazyVim",
		priority = 1000,
		opts = {
			colorscheme = "rose-pine",
		},
	},
}
