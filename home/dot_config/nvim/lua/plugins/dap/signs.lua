-- DAP Sign Definitions and Highlights
-- Configures visual appearance of breakpoints and debug indicators

local M = {}

function M.setup()
  -- Define debug symbols
  vim.fn.sign_define('DapBreakpoint', {
    text = '●',
    texthl = 'DapBreakpoint',
    linehl = '',
    numhl = 'DapBreakpoint',
  })

  vim.fn.sign_define('DapBreakpointCondition', {
    text = '◆',
    texthl = 'DapBreakpoint',
    linehl = '',
    numhl = 'DapBreakpoint',
  })

  vim.fn.sign_define('DapBreakpointRejected', {
    text = '✖',
    texthl = 'DapBreakpoint',
    linehl = '',
    numhl = 'DapBreakpoint',
  })

  vim.fn.sign_define('DapLogPoint', {
    text = '◉',
    texthl = 'DapLogPoint',
    linehl = '',
    numhl = 'DapLogPoint',
  })

  vim.fn.sign_define('DapStopped', {
    text = '→',
    texthl = 'DapStopped',
    linehl = 'DapStoppedLine',
    numhl = 'DapStopped',
  })

  -- Define highlight colors
  vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#e51400', bold = true })
  vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef', bold = true })
  vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#98c379', bold = true })
  vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#2e3440' })
end

return M
