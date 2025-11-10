-- Python Debug Configuration
-- Handles Python debugging with debugpy and C++ attachment (GDB/LLDB)

local M = {}

-- Track the last Python PID for C++ attachment
local last_pid = { python = nil }

-- Helper to find executables
local function which(bin)
  local p = vim.fn.exepath(bin)
  return (p ~= '' and p) or nil
end

function M.setup(dap)
  local py = which('python3') or which('python') or 'python'
  local gdb = which('gdb') or 'gdb'

  -- Capture PID when a Python debug session starts
  dap.listeners.after.event_process['capture-python-pid'] = function(session, body)
    if session.config and session.config.type == 'python' and body and body.systemProcessId then
      last_pid.python = body.systemProcessId
      vim.notify(('debugpy PID: %d'):format(last_pid.python), vim.log.levels.INFO)
    end
  end

  -- Clear PID when Python session ends
  dap.listeners.after.event_terminated['clear-python-pid'] = function(session)
    if session.config and session.config.type == 'python' then
      last_pid.python = nil
    end
  end

  -- Keymaps for Python debugging
  vim.keymap.set('n', '<leader>dpy', function()
    dap.run({
      type = 'python',
      request = 'launch',
      name = 'Python: current file',
      program = '${file}',
      console = 'internalConsole',
      subProcess = true,
    })
  end, { desc = 'Debug Python (debugpy)' })

  -- Attach GDB to Python process
  vim.keymap.set('n', '<leader>dpp', function()
    if not last_pid.python then
      vim.notify('No Python PID captured. Start a Python debug session first.', vim.log.levels.WARN)
      return
    end
    dap.run({
      type = 'cppdbg',
      request = 'attach',
      name = 'GDB → attach to Python',
      processId = last_pid.python,
      MIMode = 'gdb',
      miDebuggerPath = gdb,
      program = py,
      setupCommands = {
        { text = 'set breakpoint pending on' },
        { text = '-enable-pretty-printing' },
        { text = 'set stop-on-solib-events 1' },
        { text = 'set solib-search-path /root/workspace/pytorch/build/lib' },
      },
    })
  end, { desc = 'Attach GDB to Python PID' })

  -- Attach LLDB to Python process
  vim.keymap.set('n', '<leader>dpl', function()
    if not last_pid.python then
      vim.notify('No Python PID captured. Start a Python debug session first.', vim.log.levels.WARN)
      return
    end
    dap.run({
      type = 'codelldb',
      request = 'attach',
      name = 'LLDB → attach to Python',
      pid = last_pid.python,
      cwd = '/root/workspace/',
    })
  end, { desc = 'Attach LLDB to Python PID' })
end

return M
