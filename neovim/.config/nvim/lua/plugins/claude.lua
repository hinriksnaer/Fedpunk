-- Claude Code integration for Neovim
return {
  {
    "anthropic/claude-nvim",
    config = function()
      require("claude").setup({
        -- Configuration for Claude Code in Neovim
        auto_suggestions = true,
        keymaps = {
          ask = "<leader>ca",
          fix = "<leader>cf",
          explain = "<leader>ce",
          review = "<leader>cr",
        },
      })
    end,
  }
}
