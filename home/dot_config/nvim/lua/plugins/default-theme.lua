-- Default theme configuration
-- This file sets a fallback colorscheme when no fedpunk theme is active
-- theme.lua (symlinked by fedpunk-theme-set) will override this when present

return {
  {
    'LazyVim/LazyVim',
    opts = {
      -- Default to ayu-mirage if no theme is set
      colorscheme = 'ayu',
    },
  },
}
