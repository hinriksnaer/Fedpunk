-- Torrentz Hydra theme for Neovim
-- Matches the color palette from kitty/ghostty/hyprland configs
return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {
      style = "night",
      transparent = false,
      on_colors = function(c)
        -- Torrentz Hydra color palette
        c.bg            = "#0F1016"  -- background
        c.bg_dark       = "#0C0D11"  -- darker background (color0)
        c.bg_highlight  = "#272A34"  -- selection background (color8)
        c.bg_float      = "#272A34"  -- floating windows
        c.bg_sidebar    = "#0F1016"  -- sidebar background
        c.bg_statusline = "#272A34"  -- statusline background
        c.bg_popup      = "#272A34"  -- popup background

        c.fg            = "#E2E6F1"  -- foreground (color15)
        c.fg_dark       = "#A5ABB8"  -- dimmed foreground (color7)
        c.fg_gutter     = "#5A6070"  -- gutter foreground (brighter for visibility)

        c.border        = "#3D4555"  -- border color (brighter for contrast)
        c.comment       = "#6B7280"  -- comments (brighter for readability)

        -- Main colors from terminal palette
        c.red           = "#FF6A1F"  -- color1 (orange-red)
        c.orange        = "#FF9A3D"  -- color3 (yellow/orange)
        c.yellow        = "#FFC268"  -- color11 (bright yellow)
        c.green         = "#9AE64F"  -- color2
        c.cyan          = "#1BC5C9"  -- color4 (primary cyan)
        c.blue          = "#39D8DF"  -- color12 (bright blue/cyan)
        c.magenta       = "#FFC268"  -- using yellow instead of purple
        c.purple        = "#FFC268"  -- using yellow instead of purple

        -- Bright variants
        c.red1          = "#FF8140"  -- color9
        c.green1        = "#B8FF74"  -- color10
        c.cyan1         = "#5FE6E9"  -- color6
        c.cyan2         = "#8AF2F4"  -- color14

        -- Additional semantic colors
        c.git = {
          add    = c.green,
          change = c.cyan,
          delete = c.red,
        }
        c.terminal_black = c.bg_dark
      end,

      on_highlights = function(hl, c)
        -- Editor UI
        hl.Normal         = { bg = c.bg, fg = c.fg }
        hl.NormalFloat    = { bg = c.bg_float, fg = c.fg }
        hl.FloatBorder    = { bg = c.bg_float, fg = c.cyan1 }
        hl.NonText        = { fg = c.comment }
        hl.Comment        = { fg = c.comment, italic = true }

        -- Line numbers and cursor
        hl.LineNr         = { fg = c.fg_gutter }
        hl.CursorLineNr   = { fg = c.cyan, bold = true }
        hl.CursorLine     = { bg = c.bg_highlight }
        hl.Cursor         = { fg = c.bg, bg = c.cyan }

        -- Visual selection
        hl.Visual         = { bg = c.bg_highlight }
        hl.VisualNOS      = { bg = c.bg_highlight }

        -- Search
        hl.Search          = { bg = c.cyan, fg = c.bg }
        hl.IncSearch       = { bg = c.orange, fg = c.bg }
        hl.MatchParen      = { fg = c.red, bold = true }

        -- Statusline and tabs
        hl.StatusLine     = { bg = c.bg_statusline, fg = c.fg }
        hl.StatusLineNC   = { bg = c.bg_statusline, fg = c.fg_dark }
        hl.WinSeparator   = { fg = c.fg_gutter }

        hl.TabLine        = { bg = c.bg_statusline, fg = c.fg_dark }
        hl.TabLineSel     = { bg = c.cyan, fg = c.bg, bold = true }
        hl.TabLineFill    = { bg = c.bg_statusline }

        -- Popups and menus
        hl.Pmenu           = { bg = c.bg_popup, fg = c.fg_dark }
        hl.PmenuSel        = { bg = c.cyan, fg = c.bg, bold = true }
        hl.PmenuSbar       = { bg = c.bg_highlight }
        hl.PmenuThumb      = { bg = c.cyan }

        -- Diagnostics
        hl.DiagnosticError            = { fg = c.red }
        hl.DiagnosticWarn             = { fg = c.orange }
        hl.DiagnosticInfo             = { fg = c.cyan }
        hl.DiagnosticHint             = { fg = c.yellow }
        hl.DiagnosticUnderlineError   = { sp = c.red, undercurl = true }
        hl.DiagnosticUnderlineWarn    = { sp = c.orange, undercurl = true }
        hl.DiagnosticUnderlineInfo    = { sp = c.cyan, undercurl = true }
        hl.DiagnosticUnderlineHint    = { sp = c.yellow, undercurl = true }

        -- Git signs
        hl.GitSignsAdd    = { fg = c.green }
        hl.GitSignsChange = { fg = c.cyan }
        hl.GitSignsDelete = { fg = c.red }

        -- Diff
        hl.DiffAdd        = { bg = c.bg_highlight, fg = c.green }
        hl.DiffChange     = { bg = c.bg_highlight, fg = c.cyan }
        hl.DiffDelete     = { bg = c.bg_highlight, fg = c.red }
        hl.DiffText       = { bg = c.bg_highlight, fg = c.blue, bold = true }

        -- MiniIcons (file explorer icons)
        hl.MiniIconsRed    = { fg = c.red }
        hl.MiniIconsOrange = { fg = c.orange }
        hl.MiniIconsYellow = { fg = c.yellow }
        hl.MiniIconsGreen  = { fg = c.green }
        hl.MiniIconsCyan   = { fg = c.cyan }
        hl.MiniIconsBlue   = { fg = c.blue }
        hl.MiniIconsPurple = { fg = c.yellow }
        hl.MiniIconsGrey   = { fg = c.fg_dark }

        -- Telescope
        hl.TelescopeBorder          = { fg = c.cyan1, bg = c.bg_float }
        hl.TelescopePromptBorder    = { fg = c.cyan, bg = c.bg_float }
        hl.TelescopeSelection       = { bg = c.bg_highlight, fg = c.cyan, bold = true }
        hl.TelescopeMatching        = { fg = c.red, bold = true }

        -- Neo-tree
        hl.NeoTreeNormal            = { fg = c.fg, bg = c.bg }
        hl.NeoTreeDirectoryName     = { fg = c.cyan }
        hl.NeoTreeDirectoryIcon     = { fg = c.cyan }
        hl.NeoTreeFileName          = { fg = c.fg }
        hl.NeoTreeFileIcon          = { fg = c.green }
        hl.NeoTreeIndentMarker      = { fg = c.fg_gutter }
        hl.NeoTreeRootName          = { fg = c.red, bold = true }
        hl.NeoTreeGitModified       = { fg = c.cyan }
        hl.NeoTreeGitAdded          = { fg = c.green }
        hl.NeoTreeGitDeleted        = { fg = c.red }

        -- Which-key
        hl.WhichKeyNormal  = { bg = c.bg_float }
        hl.WhichKeyFloat   = { bg = c.bg_float }
        hl.WhichKeyBorder  = { bg = c.bg_float, fg = c.cyan1 }

        -- Snacks
        hl.SnacksPicker        = { bg = c.bg }
        hl.SnacksPickerList    = { bg = c.bg }
        hl.SnacksPickerPreview = { bg = c.bg }
        hl.SnacksPickerPrompt  = { bg = c.bg }
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd("colorscheme tokyonight")
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
