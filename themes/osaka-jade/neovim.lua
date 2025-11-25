-- Fedpunk theme: osaka-jade
-- Jade-inspired color palette


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
        vim.g.colors_name = 'osaka-jade'

        -- Reset highlighting
        vim.cmd('highlight clear')
        if vim.fn.exists('syntax_on') then
          vim.cmd('syntax reset')
        end

        local hl = vim.api.nvim_set_hl

        -- Osaka Jade color palette (from kitty.conf)
        local c = {
          bg            = "#111C18",  -- background
          fg            = "#C1C497",  -- foreground

          -- Dark/light variants
          bg_dark       = "#23372B",  -- color0
          bg_highlight  = "#53685B",  -- color8 (selection)
          fg_dark       = "#9EEBB3",  -- color15 (dimmed)

          -- Main colors
          red           = "#FF5345",  -- color1
          red_dim       = "#DB9F9C",  -- color9
          green         = "#549E6A",  -- color2
          green_bright  = "#63b07a",  -- color10
          yellow        = "#459451",  -- color3
          yellow_bright = "#E5C736",  -- color11
          blue          = "#509475",  -- color4
          blue_bright   = "#ACD4CF",  -- color12
          magenta       = "#D2689C",  -- color5
          cyan          = "#2DD5B7",  -- color6
          cyan_bright   = "#8CD3CB",  -- color14
          jade          = "#75BBB3",  -- color13 (signature jade)

          -- UI elements
          cursor        = "#D7C995",
          selection_bg  = "#C1C497",
          selection_fg  = "#111C18",
        }

        -- Editor UI
        hl(0, 'Normal', { bg = c.bg, fg = c.fg })
        hl(0, 'NormalFloat', { bg = c.bg_dark, fg = c.fg })
        hl(0, 'FloatBorder', { bg = c.bg_dark, fg = c.jade })
        hl(0, 'FloatTitle', { fg = c.cyan, bg = c.bg_dark, bold = true })
        hl(0, 'NonText', { fg = c.bg_highlight })
        hl(0, 'Comment', { fg = c.bg_highlight, italic = true })

        -- Line numbers and cursor
        hl(0, 'LineNr', { fg = c.bg_highlight })
        hl(0, 'CursorLineNr', { fg = c.jade, bold = true })
        hl(0, 'CursorLine', { bg = c.bg_dark })
        hl(0, 'Cursor', { fg = c.bg, bg = c.cursor })

        -- Visual selection
        hl(0, 'Visual', { bg = c.bg_highlight })
        hl(0, 'VisualNOS', { bg = c.bg_highlight })

        -- Search
        hl(0, 'Search', { bg = c.jade, fg = c.bg })
        hl(0, 'IncSearch', { bg = c.cyan, fg = c.bg })
        hl(0, 'MatchParen', { fg = c.magenta, bold = true })

        -- Syntax highlighting
        hl(0, 'Constant', { fg = c.yellow_bright })
        hl(0, 'String', { fg = c.green })
        hl(0, 'Character', { fg = c.green_bright })
        hl(0, 'Number', { fg = c.yellow_bright })
        hl(0, 'Boolean', { fg = c.yellow_bright })
        hl(0, 'Float', { fg = c.yellow_bright })
        hl(0, 'Identifier', { fg = c.fg })
        hl(0, 'Function', { fg = c.cyan })
        hl(0, 'Statement', { fg = c.jade })
        hl(0, 'Conditional', { fg = c.jade })
        hl(0, 'Repeat', { fg = c.jade })
        hl(0, 'Label', { fg = c.blue })
        hl(0, 'Operator', { fg = c.yellow })
        hl(0, 'Keyword', { fg = c.jade })
        hl(0, 'Exception', { fg = c.red })
        hl(0, 'PreProc', { fg = c.magenta })
        hl(0, 'Type', { fg = c.blue_bright })
        hl(0, 'Special', { fg = c.cyan_bright })

        -- Statusline and tabs
        hl(0, 'StatusLine', { bg = c.bg_dark, fg = c.fg })
        hl(0, 'StatusLineNC', { bg = c.bg_dark, fg = c.bg_highlight })
        hl(0, 'WinSeparator', { fg = c.bg_highlight })
        hl(0, 'TabLine', { bg = c.bg_dark, fg = c.bg_highlight })
        hl(0, 'TabLineSel', { bg = c.jade, fg = c.bg, bold = true })
        hl(0, 'TabLineFill', { bg = c.bg_dark })

        -- Popups and menus
        hl(0, 'Pmenu', { bg = c.bg_dark, fg = c.fg })
        hl(0, 'PmenuSel', { bg = c.jade, fg = c.bg, bold = true })
        hl(0, 'PmenuSbar', { bg = c.bg_highlight })
        hl(0, 'PmenuThumb', { bg = c.jade })

        -- Diagnostics
        hl(0, 'DiagnosticError', { fg = c.red })
        hl(0, 'DiagnosticWarn', { fg = c.yellow_bright })
        hl(0, 'DiagnosticInfo', { fg = c.cyan })
        hl(0, 'DiagnosticHint', { fg = c.jade })
        hl(0, 'DiagnosticUnderlineError', { sp = c.red, undercurl = true })
        hl(0, 'DiagnosticUnderlineWarn', { sp = c.yellow_bright, undercurl = true })
        hl(0, 'DiagnosticUnderlineInfo', { sp = c.cyan, undercurl = true })
        hl(0, 'DiagnosticUnderlineHint', { sp = c.jade, undercurl = true })

        -- Git signs
        hl(0, 'GitSignsAdd', { fg = c.green })
        hl(0, 'GitSignsChange', { fg = c.blue })
        hl(0, 'GitSignsDelete', { fg = c.red })

        -- Diff
        hl(0, 'DiffAdd', { bg = c.bg_dark, fg = c.green })
        hl(0, 'DiffChange', { bg = c.bg_dark, fg = c.blue })
        hl(0, 'DiffDelete', { bg = c.bg_dark, fg = c.red })
        hl(0, 'DiffText', { bg = c.bg_highlight, fg = c.blue_bright, bold = true })

        -- Telescope
        hl(0, 'TelescopeBorder', { fg = c.jade, bg = c.bg_dark })
        hl(0, 'TelescopePromptBorder', { fg = c.cyan, bg = c.bg_dark })
        hl(0, 'TelescopeSelection', { bg = c.bg_highlight, fg = c.jade, bold = true })
        hl(0, 'TelescopeMatching', { fg = c.magenta, bold = true })

        -- Neo-tree
        hl(0, 'NeoTreeNormal', { fg = c.fg, bg = c.bg })
        hl(0, 'NeoTreeDirectoryName', { fg = c.jade })
        hl(0, 'NeoTreeDirectoryIcon', { fg = c.jade })
        hl(0, 'NeoTreeFileName', { fg = c.fg })
        hl(0, 'NeoTreeFileIcon', { fg = c.green })
        hl(0, 'NeoTreeIndentMarker', { fg = c.bg_highlight })
        hl(0, 'NeoTreeRootName', { fg = c.cyan, bold = true })
        hl(0, 'NeoTreeGitModified', { fg = c.blue })
        hl(0, 'NeoTreeGitAdded', { fg = c.green })
        hl(0, 'NeoTreeGitDeleted', { fg = c.red })
      end,
    },
  },
}
