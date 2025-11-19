return {
  'obsidian-nvim/obsidian.nvim',
  version = '*',
  ft = 'markdown', -- load only for markdown
  dependencies = { 'nvim-lua/plenary.nvim' },

  -- keymaps using new command names
  keys = {
    { '<leader>nn', '<cmd>Obsidian new<CR>', desc = 'Obsidian: New Note' },
    { '<leader>ns', '<cmd>Obsidian search<CR>', desc = 'Obsidian: Search Notes' },
    { '<leader>nw', '<cmd>Obsidian quick-switch<CR>', desc = 'Obsidian: Quick Switch' },
    { '<leader>nb', '<cmd>Obsidian backlinks<CR>', desc = 'Obsidian: Backlinks' },
    { '<leader>nt', '<cmd>Obsidian template<CR>', desc = 'Obsidian: Insert Template' },
    { '<leader>np', '<cmd>Obsidian paste-img<CR>', desc = 'Obsidian: Paste Image' },
    { '<leader>nf', '<cmd>Obsidian follow<CR>', desc = 'Obsidian: Follow Link' },
  },

  opts = {
    workspaces = {
      { name = 'notes', path = vim.fn.expand '~/Documents/Notes' },
    },

    -- Disable legacy commands (use new command names instead)
    ui = { enable = false }, -- Disable UI if you prefer markdown.nvim
    legacy_commands = false,

    -- completion
    completion = { nvim_cmp = false },

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
