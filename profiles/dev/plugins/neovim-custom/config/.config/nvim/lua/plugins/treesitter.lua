-- lua/plugins/treesitter.lua
return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate', -- keep parsers up-to-date
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects' },
      { 'folke/which-key.nvim' },
    },
    keys = function()
      local wk = require 'which-key'
      wk.add {
        { '<leader>T', group = '󰦨 Treesitter' },
        { '<leader>Ti', '<cmd>TSInstallInfo<cr>', desc = 'Install info' },
        { '<leader>Tu', '<cmd>TSUpdate<cr>', desc = 'Update parsers' },
        { '<leader>Tp', '<cmd>TSPlaygroundToggle<cr>', desc = 'Toggle Playground' },
      }
      return {}
    end,
    opts = {
      ensure_installed = {
        'lua',
        'vim',
        'vimdoc',
        'python',
        'javascript',
        'typescript',
        'html',
        'css',
        'json',
        'bash',
        'markdown',
        'markdown_inline',
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<CR>',
          node_incremental = '<CR>',
          scope_incremental = '<S-CR>',
          node_decremental = '<BS>',
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
      },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
}
