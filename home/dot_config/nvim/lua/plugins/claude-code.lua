-- LazyVim plugin configuration for claude-code.nvim
return {
  -- Since this is a local plugin (not from GitHub), we use dir instead of a URL
  dir = vim.fn.stdpath("config") .. "/lua/claude-code",
  name = "claude-code.nvim",

  -- Load on startup
  lazy = false,

  -- Plugin configuration
  opts = {
    window = {
      position = "right", -- Open on right side
      width = 80,
      border = "rounded",
    },

    terminal = {
      shell = "claude",
      start_in_normal_mode = true, -- Start in normal mode, not terminal mode
    },

    keymaps = {
      toggle = "<leader>cc",
      close = "<leader>cq",
      focus = "<leader>cf",
      ask = "<leader>ca",
    },

    auto_commands = {
      close_with_q = true,
      exit_terminal_mode = true,
    },

    integration = {
      notify = true,
    },
  },

  -- Setup function
  config = function(_, opts)
    require("claude-code").setup(opts)
  end,

  -- Keybindings (additional to the ones in opts.keymaps)
  keys = {
    { "<leader>cc", "<cmd>ClaudeToggle<cr>", desc = "Toggle Claude Code" },
    { "<leader>cq", "<cmd>ClaudeClose<cr>", desc = "Close Claude Code" },
    { "<leader>cf", "<cmd>ClaudeFocus<cr>", desc = "Focus Claude Code" },
    { "<leader>ca", "<cmd>ClaudeAsk<cr>", mode = { "n", "v" }, desc = "Ask Claude" },
    { "<leader>ce", "<cmd>ClaudeExitTerminal<cr>", desc = "Exit Terminal Mode" },
    { "<leader>cb", "<cmd>ClaudeBuffers<cr>", desc = "List Buffers" },
  },
}
