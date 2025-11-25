return {
  'nvim-pack/nvim-spectre',
  dependencies = { 'nvim-lua/plenary.nvim' },
  cmd = 'Spectre',
  keys = {
    {
      '<leader>sr',
      function()
        require('spectre').open()
      end,
      desc = 'Replace (Spectre)',
    },
    {
      '<leader>sw',
      function()
        require('spectre').open_visual { select_word = true }
      end,
      desc = 'Replace word (Spectre)',
    },
    {
      '<leader>sw',
      mode = 'v',
      function()
        require('spectre').open_visual()
      end,
      desc = 'Replace selection (Spectre)',
    },
    {
      '<leader>sf',
      function()
        require('spectre').open_file_search()
      end,
      desc = 'Replace in file (Spectre)',
    },
  },
  opts = {
    open_cmd = 'vnew',
  },
}
