-- DAP UI Configuration
-- Configures nvim-dap-ui layouts and auto-open/close behavior

local M = {}

function M.setup(dap, dapui)
  -- Configure UI layouts
  dapui.setup({
    layouts = {
      -- Left sidebar: Variables and Watches
      {
        elements = {
          { id = 'scopes', size = 0.75 }, -- Variables (main focus)
          { id = 'watches', size = 0.25 }, -- Watch expressions
        },
        size = 0.25,
        position = 'left',
      },
      -- Right sidebar: Stack and Breakpoints
      {
        elements = {
          { id = 'stacks', size = 0.75 }, -- Call stack (main focus)
          { id = 'breakpoints', size = 0.25 }, -- Breakpoints
        },
        size = 0.25,
        position = 'right',
      },
      -- Bottom panel: REPL
      {
        elements = {
          { id = 'repl', size = 1.0 },
        },
        size = 0.25,
        position = 'bottom',
      },
    },
    controls = {
      enabled = true,
      element = 'repl',
    },
    floating = {
      border = 'rounded',
      mappings = { close = { 'q', '<Esc>' } },
    },
    expand_lines = true,
  })

  -- Auto-open UI when debugging starts
  dap.listeners.after.event_initialized['dapui_config'] = function()
    dapui.open()
  end

  -- Auto-close UI when debugging stops
  dap.listeners.before.event_terminated['dapui_config'] = function()
    dapui.close()
  end

  dap.listeners.before.event_exited['dapui_config'] = function()
    dapui.close()
  end
end

return M
