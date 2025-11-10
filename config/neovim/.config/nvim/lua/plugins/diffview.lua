return {
  'sindrets/diffview.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  keys = {
    { '<leader>gD', '<cmd>DiffviewOpen<CR>', desc = 'Diff View' },
    { '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', desc = 'File History' },
    { '<leader>gH', '<cmd>DiffviewFileHistory<CR>', desc = 'Repo History' },
  },
  opts = {
    enhanced_diff_hl = true,
    view = {
      default = {
        layout = 'diff2_horizontal',
      },
      file_history = {
        layout = 'diff2_horizontal',
      },
    },
  },
}
