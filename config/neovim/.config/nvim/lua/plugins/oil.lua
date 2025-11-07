return {
  {
    'stevearc/oil.nvim',
    lazy = false,
    dependencies = {
      { 'echasnovski/mini.icons', opts = {} },
      { 'folke/which-key.nvim' },
    },
    keys = function()
      local wk = require 'which-key'
      wk.add {
        { '<leader>o', group = '󰉋 Oil' },
        {
          '<leader>oo',
          function()
            require('oil').open_float()
          end,
          desc = 'Open parent dir (float)',
        },
        {
          '-',
          function()
            require('oil').open()
          end,
          desc = 'Parent dir (Oil)',
          mode = 'n',
        },
      }
      return {}
    end,
    opts = {
      default_file_explorer = true,
      columns = { 'icon', 'permissions', 'size', 'mtime' },
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name)
          return name == '.git' or name == 'node_modules'
        end,
      },
      keymaps = {
        ['<CR>'] = 'actions.select',
        ['-'] = 'actions.parent',
        ['g?'] = 'actions.show_help',
        -- Removed toggle hidden keybinding
      },
    },
  },
}
