-- Fedpunk theme: torrentz-hydra
-- Matches the color palette from kitty/ghostty/hyprland configs


-- Return empty table when imported by lazy.nvim (already configured in lazy.lua)
-- Return full spec when read by fedpunk theme system or dev profile theme-watcher
if vim.g.lazyvim_configured then
  return {}
end

return {
  {
    "LazyVim/LazyVim",
    priority = 1000,
    opts = {
      colorscheme = function()
        vim.opt.termguicolors = true
        vim.o.background = 'dark'
        vim.g.colors_name = 'torrentz-hydra'

        -- Reset highlighting
        vim.cmd('highlight clear')
        if vim.fn.exists('syntax_on') then
          vim.cmd('syntax reset')
        end

        local hl = vim.api.nvim_set_hl

        -- Torrentz Hydra color palette
        local c = {
          bg            = "#0F1016",  -- background
          bg_dark       = "#0C0D11",  -- darker background
          bg_highlight  = "#272A34",  -- selection background
          bg_float      = "#272A34",  -- floating windows
          bg_statusline = "#272A34",  -- statusline background
          bg_popup      = "#272A34",  -- popup background

          fg            = "#E2E6F1",  -- foreground
          fg_dark       = "#A5ABB8",  -- dimmed foreground
          fg_gutter     = "#5A6070",  -- gutter foreground

          border        = "#3D4555",  -- border color
          comment       = "#6B7280",  -- comments

          -- Main colors
          red           = "#FF6A1F",  -- orange-red
          orange        = "#FF9A3D",  -- yellow/orange
          yellow        = "#FFC268",  -- bright yellow
          green         = "#9AE64F",  -- green
          cyan          = "#1BC5C9",  -- primary cyan
          blue          = "#39D8DF",  -- bright blue/cyan

          -- Bright variants
          red1          = "#FF8140",
          green1        = "#B8FF74",
          cyan1         = "#5FE6E9",
          cyan2         = "#8AF2F4",
        }

        -- Editor UI
        hl(0, 'Normal', { bg = c.bg, fg = c.fg })
        hl(0, 'NormalFloat', { bg = c.bg_float, fg = c.fg })
        hl(0, 'FloatBorder', { bg = c.bg_float, fg = c.cyan1 })
        hl(0, 'NonText', { fg = c.comment })
        hl(0, 'Comment', { fg = c.comment, italic = true })

        -- Line numbers and cursor
        hl(0, 'LineNr', { fg = c.fg_gutter })
        hl(0, 'CursorLineNr', { fg = c.cyan, bold = true })
        hl(0, 'CursorLine', { bg = c.bg_highlight })
        hl(0, 'Cursor', { fg = c.bg, bg = c.cyan })

        -- Visual selection
        hl(0, 'Visual', { bg = c.bg_highlight })
        hl(0, 'VisualNOS', { bg = c.bg_highlight })

        -- Search
        hl(0, 'Search', { bg = c.cyan, fg = c.bg })
        hl(0, 'IncSearch', { bg = c.orange, fg = c.bg })
        hl(0, 'MatchParen', { fg = c.red, bold = true })

        -- Syntax
        hl(0, 'Constant', { fg = c.yellow })
        hl(0, 'String', { fg = c.green })
        hl(0, 'Character', { fg = c.green })
        hl(0, 'Number', { fg = c.yellow })
        hl(0, 'Boolean', { fg = c.yellow })
        hl(0, 'Float', { fg = c.yellow })
        hl(0, 'Identifier', { fg = c.fg })
        hl(0, 'Function', { fg = c.cyan })
        hl(0, 'Statement', { fg = c.red })
        hl(0, 'Conditional', { fg = c.red })
        hl(0, 'Repeat', { fg = c.red })
        hl(0, 'Label', { fg = c.red })
        hl(0, 'Operator', { fg = c.orange })
        hl(0, 'Keyword', { fg = c.red })
        hl(0, 'Type', { fg = c.blue })
        hl(0, 'Special', { fg = c.cyan1 })

        -- Statusline and tabs
        hl(0, 'StatusLine', { bg = c.bg_statusline, fg = c.fg })
        hl(0, 'StatusLineNC', { bg = c.bg_statusline, fg = c.fg_dark })
        hl(0, 'WinSeparator', { fg = c.fg_gutter })
        hl(0, 'TabLine', { bg = c.bg_statusline, fg = c.fg_dark })
        hl(0, 'TabLineSel', { bg = c.cyan, fg = c.bg, bold = true })
        hl(0, 'TabLineFill', { bg = c.bg_statusline })

        -- Popups and menus
        hl(0, 'Pmenu', { bg = c.bg_popup, fg = c.fg_dark })
        hl(0, 'PmenuSel', { bg = c.cyan, fg = c.bg, bold = true })
        hl(0, 'PmenuSbar', { bg = c.bg_highlight })
        hl(0, 'PmenuThumb', { bg = c.cyan })

        -- Diagnostics
        hl(0, 'DiagnosticError', { fg = c.red })
        hl(0, 'DiagnosticWarn', { fg = c.orange })
        hl(0, 'DiagnosticInfo', { fg = c.cyan })
        hl(0, 'DiagnosticHint', { fg = c.yellow })
        hl(0, 'DiagnosticUnderlineError', { sp = c.red, undercurl = true })
        hl(0, 'DiagnosticUnderlineWarn', { sp = c.orange, undercurl = true })
        hl(0, 'DiagnosticUnderlineInfo', { sp = c.cyan, undercurl = true })
        hl(0, 'DiagnosticUnderlineHint', { sp = c.yellow, undercurl = true })

        -- Git signs
        hl(0, 'GitSignsAdd', { fg = c.green })
        hl(0, 'GitSignsChange', { fg = c.cyan })
        hl(0, 'GitSignsDelete', { fg = c.red })

        -- Diff
        hl(0, 'DiffAdd', { bg = c.bg_highlight, fg = c.green })
        hl(0, 'DiffChange', { bg = c.bg_highlight, fg = c.cyan })
        hl(0, 'DiffDelete', { bg = c.bg_highlight, fg = c.red })
        hl(0, 'DiffText', { bg = c.bg_highlight, fg = c.blue, bold = true })

        -- Telescope
        hl(0, 'TelescopeBorder', { fg = c.cyan1, bg = c.bg_float })
        hl(0, 'TelescopePromptBorder', { fg = c.cyan, bg = c.bg_float })
        hl(0, 'TelescopeSelection', { bg = c.bg_highlight, fg = c.cyan, bold = true })
        hl(0, 'TelescopeMatching', { fg = c.red, bold = true })

        -- Neo-tree
        hl(0, 'NeoTreeNormal', { fg = c.fg, bg = c.bg })
        hl(0, 'NeoTreeDirectoryName', { fg = c.cyan })
        hl(0, 'NeoTreeDirectoryIcon', { fg = c.cyan })
        hl(0, 'NeoTreeFileName', { fg = c.fg })
        hl(0, 'NeoTreeFileIcon', { fg = c.green })
        hl(0, 'NeoTreeIndentMarker', { fg = c.fg_gutter })
        hl(0, 'NeoTreeRootName', { fg = c.red, bold = true })
        hl(0, 'NeoTreeGitModified', { fg = c.cyan })
        hl(0, 'NeoTreeGitAdded', { fg = c.green })
        hl(0, 'NeoTreeGitDeleted', { fg = c.red })
      end,
    },
  },
}
