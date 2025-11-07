-- Window Mode Hydra
-- Provides sticky mode for window management operations

local M = {}

-- Track last closed buffer for undo functionality
local last_closed_buf = nil
local last_closed_win_config = nil

-- Set up autocmd to track closed windows
local function setup_window_tracking()
  vim.api.nvim_create_autocmd('WinClosed', {
    callback = function(args)
      local win = tonumber(args.match)
      if win and vim.api.nvim_win_is_valid(win) then
        last_closed_buf = vim.api.nvim_win_get_buf(win)
        last_closed_win_config = vim.api.nvim_win_get_config(win)
      end
    end,
  })
end

-- Helper function to restore last closed window
local function undo_close()
  if last_closed_buf and vim.api.nvim_buf_is_valid(last_closed_buf) then
    vim.cmd('vsplit')
    vim.api.nvim_win_set_buf(0, last_closed_buf)
    vim.notify('Reopened last closed window', vim.log.levels.INFO)
  else
    vim.notify('No window to restore', vim.log.levels.WARN)
  end
end

function M.setup(hydra)
  -- Initialize window tracking
  setup_window_tracking()

  M.hydra_instance = hydra({
    name = 'Window Mode',
    hint = [[
 Navigate: _h_ _j_ _k_ _l_ _w_   Split: _s_plit  _v_ertical
 ^
 Resize: _<_ _>_ width   _+_ _-_ height   _=_ equal
 ^
 Close: _c_lose  _u_ndo close  _q_uit
 ^
 Switch: _D_ebug Mode   _<Esc>_: exit
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
    body = '<leader>w',
    heads = {
      -- Navigate windows
      { 'h', '<C-w>h', { desc = 'Go left' } },
      { 'j', '<C-w>j', { desc = 'Go down' } },
      { 'k', '<C-w>k', { desc = 'Go up' } },
      { 'l', '<C-w>l', { desc = 'Go right' } },
      { 'w', '<C-w>w', { desc = 'Next window' } },

      -- Split windows
      { 's', '<C-w>s', { desc = 'Split horizontal' } },
      { 'v', '<C-w>v', { desc = 'Split vertical' } },

      -- Resize windows
      { '<', '<C-w>5<', { desc = 'Decrease width' } },
      { '>', '<C-w>5>', { desc = 'Increase width' } },
      { '+', '<C-w>5+', { desc = 'Increase height' } },
      { '-', '<C-w>5-', { desc = 'Decrease height' } },
      { '=', '<C-w>=', { desc = 'Equal size' } },

      -- Close operations
      { 'c', '<C-w>c', { desc = 'Close window' } },
      { 'u', undo_close, { desc = 'Undo close (restore last)' } },
      { 'q', ':q<CR>', { desc = 'Quit window', exit = true } },

      -- Switch to other hydra modes
      {
        'D',
        function()
          local debug = require('plugins.hydra.debug')
          if debug.hydra_instance then
            debug.hydra_instance:activate()
          end
        end,
        { exit = true, desc = 'Switch to Debug Mode' },
      },

      -- Exit
      { '<Esc>', nil, { exit = true, desc = 'Exit' } },
    },
  })
end

return M
