-- fzf-lua - Fast, feature-rich fuzzy finder
-- Uses native fzf for blazing speed with great defaults

return {
  'ibhagwan/fzf-lua',
  lazy = false, -- Load immediately
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    local actions = require 'fzf-lua.actions'

    require('fzf-lua').setup {
      -- Use fzf-native for best performance
      'default-title',

      winopts = {
        height = 0.85,
        width = 0.80,
        row = 0.35,
        col = 0.50,
        border = 'rounded',
        preview = {
          default = 'bat',
          border = 'border',
          wrap = 'nowrap',
          hidden = 'nohidden', -- Start with preview visible
          vertical = 'down:45%',
          horizontal = 'right:50%',
          layout = 'flex',
          flip_columns = 120,
          scrollbar = 'float',
        },
      },

      keymap = {
        builtin = {
          ['<C-d>'] = 'preview-page-down',
          ['<C-u>'] = 'preview-page-up',
        },
        fzf = {
          ['ctrl-q'] = 'select-all+accept',
          ['ctrl-d'] = 'preview-page-down',
          ['ctrl-u'] = 'preview-page-up',
        },
      },

      files = {
        prompt = 'Files❯ ',
        multiprocess = true,
        git_icons = true,
        file_icons = true,
        color_icons = true,
        find_opts = [[-type f -not -path '*/\.git/*' -printf '%P\n']],
        rg_opts = [[--color=never --files --hidden --follow -g "!.git"]],
        fd_opts = [[--color=never --type f --hidden --follow --exclude .git]],
      },

      grep = {
        prompt = 'Rg❯ ',
        input_prompt = 'Grep For❯ ',
        multiprocess = true,
        git_icons = true,
        file_icons = true,
        color_icons = true,
        rg_opts = [[--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e]],
      },

      buffers = {
        prompt = 'Buffers❯ ',
        file_icons = true,
        color_icons = true,
        sort_lastused = true,
        actions = {
          ['ctrl-x'] = { fn = actions.buf_del, reload = true },
        },
      },

      oldfiles = {
        prompt = 'History❯ ',
        cwd_only = true,
        stat_file = true,
        include_current_session = true,
      },

      helptags = {
        prompt = 'Help❯ ',
        actions = {
          ['default'] = actions.help,
        },
      },

      lsp = {
        prompt_postfix = '❯ ',
        cwd_only = false,
        async_or_timeout = 5000,
        file_icons = true,
        git_icons = false,
        lsp_icons = true,
        severity = 'hint',
      },
    }

    -- Set up keybindings
    local wk = require 'which-key'
    wk.add {
      { '<leader>f', group = ' Find' },

      -- Files and buffers
      {
        '<leader>ff',
        '<cmd>FzfLua files<cr>',
        desc = 'Find Files',
      },
      {
        '<C-p>',
        '<cmd>FzfLua files<cr>',
        desc = 'Find Files',
        mode = 'n',
      },
      {
        '<leader>fb',
        '<cmd>FzfLua buffers<cr>',
        desc = 'Buffers',
      },
      {
        '<leader>fo',
        '<cmd>FzfLua oldfiles<cr>',
        desc = 'Recent Files',
      },

      -- Search
      {
        '<leader>fg',
        '<cmd>FzfLua live_grep<cr>',
        desc = 'Live Grep',
      },
      {
        '<leader>fw',
        '<cmd>FzfLua grep_cword<cr>',
        desc = 'Grep Word Under Cursor',
      },
      {
        '<leader>/',
        '<cmd>FzfLua blines<cr>',
        desc = 'Fuzzy in Current Buffer',
      },

      -- Help and info
      {
        '<leader>fh',
        '<cmd>FzfLua help_tags<cr>',
        desc = 'Help',
      },
      {
        '<leader>fk',
        '<cmd>FzfLua keymaps<cr>',
        desc = 'Keymaps',
      },
      {
        '<leader>fm',
        '<cmd>FzfLua marks<cr>',
        desc = 'Marks',
      },
      {
        '<leader>fr',
        '<cmd>FzfLua resume<cr>',
        desc = 'Resume',
      },
      {
        '<leader>fc',
        '<cmd>FzfLua colorschemes<cr>',
        desc = 'Colorschemes',
      },

      -- LSP (if needed)
      {
        '<leader>fs',
        '<cmd>FzfLua lsp_document_symbols<cr>',
        desc = 'Document Symbols',
      },
    }
  end,
}
