return {
  {
    'mikavilpas/yazi.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'folke/which-key.nvim' },
    },
    keys = function()
      local wk = require 'which-key'
      wk.add {
        -- Quick access with dash (replaces Oil)
        {
          '-',
          function()
            require('yazi').yazi()
          end,
          desc = 'Open Yazi (cwd)',
          mode = 'n',
        },
        -- Leader key alternatives
        {
          '<leader>e',
          function()
            require('yazi').yazi()
          end,
          desc = 'Explorer (Yazi)',
          mode = 'n',
        },
        {
          '<leader>E',
          function()
            require('yazi').yazi(nil, vim.fn.expand '%:p:h')
          end,
          desc = 'Explorer (current file dir)',
          mode = 'n',
        },
      }
      return {}
    end,
    opts = {
      -- Enable yazi as default file manager
      open_for_directories = true, -- Yazi opens when you try to open a directory

      -- Keymappings inside yazi
      keymaps = {
        show_help = '<f1>',
        open_file_in_vertical_split = '<c-v>',
        open_file_in_horizontal_split = '<c-x>',
        open_file_in_tab = '<c-t>',
        grep_in_directory = '<c-s>',
        replace_in_directory = '<c-g>',
        cycle_open_buffers = '<tab>',
        copy_relative_path_to_selected_files = '<c-y>',
        send_to_quickfix_list = '<c-q>',
      },

      -- Integration settings
      use_ya_for_events_reading = true,
      use_yazi_client_id_flag = true,

      -- Floating window settings
      floating_window_scaling_factor = 0.9,
      yazi_floating_window_winblend = 0,
      yazi_floating_window_border = 'rounded',

      -- Log level (for debugging)
      log_level = vim.log.levels.OFF,

      -- Hooks
      hooks = {
        yazi_opened = function()
          -- Optionally set a different colorscheme when yazi opens
          -- vim.cmd 'colorscheme habamax'
        end,
        yazi_closed_successfully = function(chosen_file, config)
          -- Called when yazi closes successfully
          -- You can add custom logic here
        end,
      },

      -- Use the `ya` binary for better performance
      open_file_function = function(chosen_file, config, state)
        -- Default behavior: open the file in the current window
        vim.cmd('edit ' .. chosen_file)
      end,

      -- Highlight groups customization
      highlight_groups = {
        hovered_buffer = { link = 'Visual' },
      },
    },
  },
}
