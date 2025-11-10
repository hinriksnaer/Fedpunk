return {
  'obsidian-nvim/obsidian.nvim',
  version = '*',
  ft = 'markdown', -- load only for markdown
  dependencies = { 'nvim-lua/plenary.nvim' },

  -- keymaps live here; commands exist because we configure them in opts below
  keys = {
    { '<leader>nn', '<cmd>ObsidianNew<CR>', desc = 'Obsidian: New Note' },
    { '<leader>ns', '<cmd>ObsidianSearch<CR>', desc = 'Obsidian: Search Notes' },
    { '<leader>nw', '<cmd>ObsidianQuickSwitch<CR>', desc = 'Obsidian: Quick Switch' },
    { '<leader>nb', '<cmd>ObsidianBacklinks<CR>', desc = 'Obsidian: Backlinks' },
    { '<leader>nt', '<cmd>ObsidianTemplate<CR>', desc = 'Obsidian: Insert Template' },
    { '<leader>np', '<cmd>ObsidianPasteImg<CR>', desc = 'Obsidian: Paste Image' },
    { '<leader>nf', '<cmd>ObsidianFollowLink<CR>', desc = 'Obsidian: Follow Link' },
  },

  opts = {
    workspaces = {
      { name = 'notes', path = vim.fn.expand '~/Documents/Notes' },
    },

    -- completion
    completion = { nvim_ = false },

    -- new notes behavior
    new_notes_location = 'current_dir',

    -- templates (needed for :ObsidianTemplate to work without errors)
    templates = {
      subdir = 'templates',
      date_format = '%Y-%m-%d',
      time_format = '%H:%M',
    },

    -- images (needed for :ObsidianPasteImg)
    -- ensure you have an images folder in your vault
    attachments = {
      img_dir = 'images',
      img_name_func = function()
        return os.date 'img-%Y%m%d-%H%M%S'
      end,
    },

    -- daily notes optional
    daily_notes = { folder = 'dailies' },
  },
}
