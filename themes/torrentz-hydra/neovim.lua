-- ~/.config/nvim/lua/plugins/hydrant-pressure.lua
return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      on_colors = function(c)
        c.bg            = "#000000"
        c.bg_dark       = "#272625"
        c.bg_float      = "#434142"
        c.bg_sidebar    = "#272625"
        c.bg_statusline = "#272625"
        c.fg            = "#ECEBE2"
        c.fg_dark       = "#C8C8B9"
        c.fg_gutter     = "#635B58"
        c.border        = "#434142"
        c.comment       = "#857079"
        c.orange        = "#FB6F58"
        c.yellow        = "#FEA193"
        c.red           = "#E23914"
        c.blue          = "#1F6DA2"
        c.cyan          = "#00BDD5"
        c.green         = "#00A355"
        c.magenta       = "#9D9B94"
      end,

      on_highlights = function(hl, c)
        hl.Normal         = { bg = c.bg, fg = c.fg }
        hl.NonText        = { fg = c.comment }
        hl.Comment        = { fg = c.comment, italic = true }
        hl.LineNr         = { fg = c.fg_gutter }
        hl.CursorLineNr   = { fg = c.orange, bold = true }
        hl.CursorLine     = { bg = "#1A1919" }
        hl.Visual         = { bg = "#434142" }
        hl.StatusLine     = { bg = c.bg_dark, fg = c.fg }
        hl.StatusLineNC   = { bg = c.bg_dark, fg = c.comment }
        hl.WinSeparator   = { fg = c.border }

        hl.TabLine        = { bg = c.bg_dark, fg = c.comment }
        hl.TabLineSel     = { bg = c.cyan, fg = c.bg }
        hl.TabLineFill    = { bg = c.bg_dark }

        hl.DiagnosticWarn          = { fg = c.yellow }
        hl.DiagnosticError         = { fg = c.red }
        hl.DiagnosticInfo          = { fg = c.cyan }
        hl.DiagnosticHint          = { fg = c.magenta }
        hl.DiagnosticUnderlineWarn = { sp = c.yellow, undercurl = true }
        hl.DiagnosticUnderlineError= { sp = c.red, undercurl = true }
        hl.DiagnosticUnderlineInfo = { sp = c.cyan, undercurl = true }
        hl.DiagnosticUnderlineHint = { sp = c.magenta, undercurl = true }


        hl.MiniIconsRed    = { fg = c.red }
        hl.MiniIconsBlue   = { fg = c.blue }
        hl.MiniIconsGreen  = { fg = c.green }
        hl.MiniIconsYellow = { fg = c.orange }
        hl.MiniIconsOrange = { fg = c.orange }
        hl.MiniIconsPurple = { fg = c.magenta }
        hl.MiniIconsCyan   = { fg = c.cyan }


        hl.Pmenu           = { bg = "#1A1919", fg = c.fg_dark }
        hl.PmenuSel        = { bg = c.cyan, fg = c.bg }
        hl.Search          = { bg = c.orange, fg = c.bg }
        hl.IncSearch       = { bg = c.yellow, fg = c.bg }
        hl.MatchParen      = { fg = c.orange, bold = true }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "tokyonight" },
  },
}
