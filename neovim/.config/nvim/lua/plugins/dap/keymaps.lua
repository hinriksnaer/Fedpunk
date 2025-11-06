-- DAP Standalone Keymaps
-- Defines keybindings that are used outside of Debug Mode hydra

local M = {}

function M.setup(dap, dapui)
  -- Toggle breakpoint (quick access without entering Debug Mode)
  vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Toggle Breakpoint' })

  -- Evaluate selection in visual mode (can't be in Hydra)
  vim.keymap.set('v', '<leader>de', dapui.eval, { desc = 'Evaluate Selection' })
end

return M
