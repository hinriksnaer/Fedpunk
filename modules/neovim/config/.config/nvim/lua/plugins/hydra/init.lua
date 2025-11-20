-- Hydra - Debug Mode Only
-- Modal keybindings for DAP debugging workflow

return {
  'nvimtools/hydra.nvim',
  keys = {
    { '<leader>dm', desc = 'Debug Mode (Hydra)' },
  },
  config = function()
    local Hydra = require('hydra')

    -- Load debug hydra only
    local debug = require('plugins.hydra.debug')
    debug.setup(Hydra)
  end,
}
