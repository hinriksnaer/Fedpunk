-- Hydra Configuration Loader
-- Loads all hydra modes from modular files

return {
  'nvimtools/hydra.nvim',
  keys = {
    { '<leader>dm', desc = 'Debug Mode' },
    { '<leader>w', desc = 'Window Mode' },
    { '<leader>t', desc = 'Tmux Mode' },
  },
  config = function()
    local Hydra = require('hydra')

    -- Load debug hydra
    local debug = require('plugins.hydra.debug')
    debug.setup(Hydra)

    -- Load window hydra
    local window = require('plugins.hydra.window')
    window.setup(Hydra)

    -- Load tmux hydra
    local tmux = require('plugins.hydra.tmux')
    tmux.setup(Hydra)
  end,
}
