# Neovim Configuration (Default Profile)

This directory contains the Neovim configuration for the **default profile** only.

## Dynamic LazyVim Setup

The `nvim/` directory is **NOT tracked in git**. Instead, it is dynamically generated during installation:

1. **Before deployment** (`modules/neovim/scripts/before`):
   - Clones the latest [LazyVim starter](https://github.com/LazyVim/starter)
   - Removes `.git` directory
   - Applies fedpunk customizations to `lua/config/lazy.lua`:
     - Reads theme colorscheme from `~/.config/nvim/lua/plugins/theme.lua`
     - Sets `vim.g.lazyvim_configured = true` flag
     - Disables LazyVim import order check
     - Passes colorscheme to LazyVim opts

2. **Stow deployment**:
   - Symlinks the generated config to `~/.config/nvim/`

## Why This Approach?

- **Always up-to-date**: Fresh LazyVim starter on every installation
- **Clean git history**: No tracking of third-party LazyVim files
- **Fedpunk integration**: Automatic theme system integration
- **Easy updates**: Just re-run the installer to get latest LazyVim

## Dev Profile

The **dev profile** uses a completely different Neovim configuration located at:
`profiles/dev/plugins/neovim-custom/`

This allows advanced users to have a custom Neovim setup while default users get the batteries-included LazyVim experience.
