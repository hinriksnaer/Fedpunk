return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  build = ':Copilot auth',
  event = 'BufReadPost',
  opts = {
    suggestion = {
      enabled = not vim.g.ai_cmp,
      auto_trigger = true,
      hide_during_completion = vim.g.ai_cmp,
      keymap = {
        accept = '<C-y>',      -- Ctrl+y to accept (common completion binding)
        next = '<M-]>',
        prev = '<M-[>',
        dismiss = '<C-e>',     -- Ctrl+e to dismiss (common completion binding)
      },
    },
    panel = { enabled = false },
    filetypes = {
      markdown = true,
      help = true,
    },
  },
}
