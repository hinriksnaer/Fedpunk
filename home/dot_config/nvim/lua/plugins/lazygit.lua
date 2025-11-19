return {
  'kdheepak/lazygit.nvim',
  lazy = true,
  cmd = {
    'LazyGit',
    'LazyGitConfig',
    'LazyGitCurrentFile',
    'LazyGitFilter',
    'LazyGitFilterCurrentFile',
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'folke/which-key.nvim',
  },

  -- let lazy.nvim create a lazy-loaded keymap
  keys = {
    { '<leader>gg', '<cmd>LazyGit<cr>', desc = ' LazyGit' },
  },
}
