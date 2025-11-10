-- lua/plugins/fuzzy.lua
return {
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    version = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'folke/which-key.nvim' },
      { -- native fzf speedup (optional but recommended)
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    keys = function()
      local builtin = require 'telescope.builtin'
      local themes = require 'telescope.themes'
      local wk = require 'which-key'

      -- handy dropdown for in-buffer search
      local function buf_fuzzy()
        builtin.current_buffer_fuzzy_find(themes.get_dropdown {
          previewer = false,
          winblend = 10,
        })
      end

      wk.add {
        { '<leader>f', group = ' Find' },
        { '<leader>ff', builtin.find_files, desc = 'Files' },
        { '<leader>fg', builtin.live_grep, desc = 'Grep (ripgrep)' },
        { '<leader>fb', builtin.buffers, desc = 'Buffers' },
        { '<leader>fh', builtin.help_tags, desc = 'Help' },
        { '<leader>fr', builtin.resume, desc = 'Resume last picker' },
        { '<leader>fs', builtin.grep_string, desc = 'Grep word under cursor' },
        { '<leader>fd', builtin.diagnostics, desc = 'Diagnostics' },
        { '<leader>ft', builtin.colorscheme, desc = 'Themes' },
        { '<leader>/', buf_fuzzy, desc = 'Fuzzy in current buffer' },
        { '<C-p>', builtin.find_files, desc = 'Files', mode = 'n' },
      }
      return {}
    end,
    opts = function()
      local actions = require 'telescope.actions'
      return {
        defaults = {
          prompt_prefix = '  ',
          selection_caret = ' ',
          path_display = { 'smart' },
          sorting_strategy = 'ascending',
          layout_config = { prompt_position = 'top' },
          mappings = {
            i = {
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
              ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
              ['<Esc>'] = actions.close,
            },
          },
        },
        pickers = {
          find_files = { hidden = true }, -- show dotfiles too
          colorscheme = {
            enable_preview = true, -- live preview themes as you hover
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
          },
        },
      }
    end,
    config = function(_, opts)
      require('telescope').setup(opts)
      pcall(require('telescope').load_extension, 'fzf')
    end,
  },
}
