-- Tmux Mode Hydra
-- Provides sticky mode for tmux operations from within Neovim

local M = {}

function M.setup(hydra)
  M.hydra_instance = hydra({
    name = 'Tmux Mode',
    hint = [[
 Navigate: _h_ _j_ _k_ _l_   Split: _s_plit  _v_ertical
 ^
 Windows: _n_ext  _p_rev  _c_reate  _x_ close  Swap: _H_ left  _L_ right
 ^
 Resize: _<_ _>_ width   _+_ _-_ height
 ^
 Sessions: _d_etach  _z_ zoom pane
 ^
 Switch: _W_indow Mode  _D_ebug Mode   _<Esc>_: exit
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
    body = '<leader>t',
    heads = {
      -- Navigate tmux panes
      {
        'h',
        function()
          vim.fn.system('tmux select-pane -L')
        end,
        { desc = 'Go left' },
      },
      {
        'j',
        function()
          vim.fn.system('tmux select-pane -D')
        end,
        { desc = 'Go down' },
      },
      {
        'k',
        function()
          vim.fn.system('tmux select-pane -U')
        end,
        { desc = 'Go up' },
      },
      {
        'l',
        function()
          vim.fn.system('tmux select-pane -R')
        end,
        { desc = 'Go right' },
      },

      -- Split panes
      {
        's',
        function()
          vim.fn.system('tmux split-window -v')
        end,
        { desc = 'Split horizontal' },
      },
      {
        'v',
        function()
          vim.fn.system('tmux split-window -h')
        end,
        { desc = 'Split vertical' },
      },

      -- Resize panes
      {
        '<',
        function()
          vim.fn.system('tmux resize-pane -L 5')
        end,
        { desc = 'Decrease width' },
      },
      {
        '>',
        function()
          vim.fn.system('tmux resize-pane -R 5')
        end,
        { desc = 'Increase width' },
      },
      {
        '+',
        function()
          vim.fn.system('tmux resize-pane -U 5')
        end,
        { desc = 'Increase height' },
      },
      {
        '-',
        function()
          vim.fn.system('tmux resize-pane -D 5')
        end,
        { desc = 'Decrease height' },
      },

      -- Window management
      {
        'n',
        function()
          vim.fn.system('tmux next-window')
        end,
        { desc = 'Next window' },
      },
      {
        'p',
        function()
          vim.fn.system('tmux previous-window')
        end,
        { desc = 'Previous window' },
      },
      {
        'c',
        function()
          vim.fn.system('tmux new-window')
        end,
        { desc = 'Create window' },
      },
      {
        'x',
        function()
          vim.fn.system('tmux kill-pane')
        end,
        { desc = 'Close pane' },
      },

      -- Swap windows
      {
        'H',
        function()
          vim.fn.system('tmux swap-window -d -t -1')
        end,
        { desc = 'Swap window left' },
      },
      {
        'L',
        function()
          vim.fn.system('tmux swap-window -d -t +1')
        end,
        { desc = 'Swap window right' },
      },

      -- Session operations
      {
        'd',
        function()
          vim.fn.system('tmux detach-client')
        end,
        { exit = true, desc = 'Detach session' },
      },
      {
        'z',
        function()
          vim.fn.system('tmux resize-pane -Z')
        end,
        { desc = 'Toggle zoom pane' },
      },

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
