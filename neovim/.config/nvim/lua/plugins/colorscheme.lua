return {
  -- Catppuccin theme - popular pastel theme with multiple flavors
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    opts = {
      flavour = 'mocha', -- latte, frappe, macchiato, mocha
      transparent_background = false,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        telescope = true,
        which_key = true,
        dap = true,
        dap_ui = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { 'italic' },
            hints = { 'italic' },
            warnings = { 'italic' },
            information = { 'italic' },
          },
          underlines = {
            errors = { 'underline' },
            hints = { 'underline' },
            warnings = { 'underline' },
            information = { 'underline' },
          },
        },
      },
    },
  },

  -- TokyoNight - vibrant dark theme
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    opts = {
      style = 'night', -- storm, moon, night, day
      transparent = false,
      styles = {
        comments = { italic = false },
        sidebars = 'dark',
        floats = 'dark',
      },
    },
  },

  -- Panda - VSCode's superminimal dark syntax theme
  {
    'markvincze/panda-vim',
    priority = 1000,
  },

  -- Ayu - Simple, bright and elegant theme
  {
    'Shatur/neovim-ayu',
    priority = 1000,
    config = function()
      require('ayu').setup {
        mirage = true, -- Set to true for mirage variant
      }
    end,
  },

  -- Set default colorscheme
  {
    'Shatur/neovim-ayu',
    config = function()
      require('ayu').setup {
        mirage = true,
      }
      vim.cmd.colorscheme 'ayu'
    end,
  },
}
