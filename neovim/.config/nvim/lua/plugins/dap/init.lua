-- DAP (Debug Adapter Protocol) Configuration Loader
-- Main plugin specification and module loader

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'theHamsta/nvim-dap-virtual-text',
  },
  config = function()
    local dap = require('dap')
    local dapui = require('dapui')

    -- Load modular configurations
    require('plugins.dap.signs').setup()
    require('plugins.dap.adapters').setup(dap)
    require('plugins.dap.python').setup(dap)
    require('plugins.dap.ui').setup(dap, dapui)
    require('plugins.dap.keymaps').setup(dap, dapui)

    -- Setup virtual text (inline variable values)
    require('nvim-dap-virtual-text').setup({})
  end,
}
