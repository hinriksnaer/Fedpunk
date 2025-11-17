-- Debug Mode Hydra
-- Provides sticky mode for DAP debugging operations

local M = {}

-- Helper function to focus a DAP UI element
local function focus_element(element_name)
  return function()
    local windows = require('dapui.windows')
    for _, win in pairs(windows.layouts) do
      for _, buf in pairs(win.buffers()) do
        if buf.element == element_name then
          vim.api.nvim_set_current_win(buf.win())
          return
        end
      end
    end
    vim.notify('DAP UI element "' .. element_name .. '" not found', vim.log.levels.WARN)
  end
end

-- Helper function to jump to stopped location
local function goto_stopped()
  local dap = require('dap')
  local session = dap.session()
  if session then
    local frame = session.current_frame
    if frame and frame.source and frame.source.path then
      vim.cmd('edit ' .. vim.fn.fnameescape(frame.source.path))
      vim.api.nvim_win_set_cursor(0, { frame.line, frame.column - 1 })
      vim.cmd('normal! zz')
    end
  end
end

function M.setup(hydra)
  M.hydra_instance = hydra({
    name = 'Debug Mode',
    hint = [[
 Step: _n_: over  _i_: into  _o_: out  _s_: continue  _c_: cursor
 ^
 Control: _b_: breakpoint  _t_: terminate  _g_: goto stopped  _[_/_]_: up/down stack
 ^
 UI: _x_: toggle UI  _e_: eval  _d_: hover
 ^
 Focus: _v_: vars  _w_: watch  _r_: repl  _1_: stack  _2_: breaks
 Float: _V_: vars  _R_: repl  _!_: stack
 ^
 Switch: _W_indow Mode   _q_/_<Esc>_: exit
]],
    config = {
      color = 'pink',
      invoke_on_body = true,
      hint = {
        type = 'window',
        position = 'bottom',
        float_opts = {
          border = 'rounded',
          style = 'minimal',
          focusable = false,
          noautocmd = true,
        },
      },
    },
    mode = 'n',
    body = '<leader>dm',
    heads = {
      -- Step commands
      { 'n', function() require('dap').step_over() end, { desc = 'Step Over (Next)' } },
      { 'i', function() require('dap').step_into() end, { desc = 'Step Into' } },
      { 'o', function() require('dap').step_out() end, { desc = 'Step Out' } },
      { 's', function() require('dap').continue() end, { desc = 'Continue (Start)' } },
      { 'c', function() require('dap').run_to_cursor() end, { desc = 'Run to Cursor' } },

      -- Control
      { 'b', function() require('dap').toggle_breakpoint() end, { desc = 'Toggle Breakpoint' } },
      { 't', function() require('dap').terminate() end, { desc = 'Terminate', exit = true } },
      { 'g', goto_stopped, { desc = 'Goto Stopped Location' } },
      { '[', function() require('dap').up() end, { desc = 'Up Stack' } },
      { ']', function() require('dap').down() end, { desc = 'Down Stack' } },

      -- UI
      { 'x', function() require('dapui').toggle() end, { desc = 'Toggle DAP UI' } },
      { 'e', function() require('dapui').eval() end, { desc = 'Eval Expression' } },
      { 'd', function() require('dap.ui.widgets').hover() end, { desc = 'Hover (Details)' } },

      -- Focus windows
      { 'v', focus_element('scopes'), { desc = 'Focus Variables' } },
      { 'w', focus_element('watches'), { desc = 'Focus Watches' } },
      { 'r', focus_element('repl'), { desc = 'Focus REPL' } },
      { '1', focus_element('stacks'), { desc = 'Focus Stack' } },
      { '2', focus_element('breakpoints'), { desc = 'Focus Breakpoints' } },

      -- Float windows
      { 'V', function() require('dapui').float_element('scopes', { enter = true }) end, { desc = 'Float Variables' } },
      { 'R', function() require('dapui').float_element('repl', { enter = true }) end, { desc = 'Float REPL' } },
      { '!', function() require('dapui').float_element('stacks', { enter = true }) end, { desc = 'Float Stack' } },

      -- Switch to other hydra modes
      {
        'W',
        function()
          local window = require('plugins.hydra.window')
          if window.hydra_instance then
            window.hydra_instance:activate()
          end
        end,
        { exit = true, desc = 'Switch to Window Mode' },
      },

      -- Exit
      { 'q', nil, { exit = true, desc = 'Exit' } },
      { '<Esc>', nil, { exit = true, desc = 'Exit' } },
    },
  })
end

return M
