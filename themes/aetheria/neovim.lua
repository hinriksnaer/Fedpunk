-- Aetheria Theme for Neovim
-- Inspired by Audio Waveform Omarchy colorscheme and Base16-Tarot color palette


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
                -- Dark color palette
                local colors = {
                    -- Base colors (matching kitty)
                    hex_0e091d = '#0e091d', -- Background
                    hex_000000 = '#000000', -- Black (color0)
                    hex_1a1520 = '#1a1520', -- Slightly lighter than bg

                    -- Main foreground (matching kitty)
                    hex_14B9B5 = '#14B9B5', -- Cyan foreground (kitty fg)
                    hex_11AEB3 = '#11AEB3', -- Bright cyan (color15)

                    -- Normal colors from kitty
                    hex_c8e967 = '#c8e967', -- Green (color1)
                    hex_E20342 = '#E20342', -- Red (color2)
                    hex_7cd699 = '#7cd699', -- Light green (color3)
                    hex_BE3F50 = '#BE3F50', -- Dark red (color4)
                    hex_9147a8 = '#9147a8', -- Purple (color5)
                    hex_FF7F41 = '#FF7F41', -- Orange (color6)
                    hex_A60234 = '#A60234', -- Dark red (color7)

                    -- Bright colors from kitty
                    hex_c53253 = '#c53253', -- Bright red-ish (color8)
                    hex_CE4F48 = '#CE4F48', -- Bright red (color9)
                    hex_f93d3b = '#f93d3b', -- Vibrant red (color10)
                    hex_FD3E6A = '#FD3E6A', -- Pink-red (color11)
                    hex_04C5F0 = '#04C5F0', -- Bright cyan (color12)
                    hex_6C032C = '#6C032C', -- Dark maroon (color13)
                    hex_ffbe74 = '#ffbe74', -- Orange-yellow (color14)
                }
                ---@diagnostic disable: undefined-global
                -- Reset highlighting
                vim.cmd('highlight clear')
                if vim.fn.exists('syntax_on') then
                    vim.cmd('syntax reset')
                end

                vim.o.termguicolors = true
                vim.o.background = 'dark'
                vim.g.colors_name = 'aetheria'

                local hl = vim.api.nvim_set_hl

                -- Editor highlights
                hl(0, 'Normal', { fg = colors.hex_14B9B5, bg = colors.hex_0e091d })
                hl(0, 'NormalFloat', { fg = colors.hex_14B9B5, bg = colors.hex_1a1520 })
                hl(0, 'FloatBorder', { fg = colors.hex_9147a8, bg = colors.hex_1a1520 })
                hl(0, 'FloatTitle', { fg = colors.hex_04C5F0, bg = colors.hex_1a1520, bold = true })
                hl(0, 'Cursor', { fg = colors.hex_0e091d, bg = colors.hex_FF7F41 })
                hl(0, 'CursorLine', { bg = colors.hex_1a1520 })
                hl(0, 'CursorLineNr', { fg = colors.hex_04C5F0, bold = true })
                hl(0, 'LineNr', { fg = colors.hex_9147a8 })
                hl(0, 'Visual', { bg = colors.hex_BE3F50 })
                hl(0, 'VisualNOS', { bg = colors.hex_BE3F50 })
                hl(0, 'Search', { fg = colors.hex_0e091d, bg = colors.hex_04C5F0 })
                hl(0, 'IncSearch', { fg = colors.hex_0e091d, bg = colors.hex_FF7F41 })
                hl(0, 'MatchParen', { fg = colors.hex_FD3E6A, bold = true })

                -- Syntax highlighting
                hl(0, 'Comment', { fg = colors.hex_6C032C, italic = true })
                hl(0, 'Constant', { fg = colors.hex_ffbe74 })
                hl(0, 'String', { fg = colors.hex_FF7F41 })
                hl(0, 'Character', { fg = colors.hex_FF7F41 })
                hl(0, 'Number', { fg = colors.hex_ffbe74 })
                hl(0, 'Boolean', { fg = colors.hex_ffbe74 })
                hl(0, 'Float', { fg = colors.hex_ffbe74 })
                hl(0, 'Identifier', { fg = colors.hex_14B9B5 })
                hl(0, 'Function', { fg = colors.hex_7cd699 })
                hl(0, 'Statement', { fg = colors.hex_9147a8 })
                hl(0, 'Conditional', { fg = colors.hex_9147a8 })
                hl(0, 'Repeat', { fg = colors.hex_9147a8 })
                hl(0, 'Label', { fg = colors.hex_E20342 })
                hl(0, 'Operator', { fg = colors.hex_c8e967 })
                hl(0, 'Keyword', { fg = colors.hex_9147a8 })
                hl(0, 'Exception', { fg = colors.hex_f93d3b })
                hl(0, 'PreProc', { fg = colors.hex_FD3E6A })
                hl(0, 'Include', { fg = colors.hex_FD3E6A })
                hl(0, 'Define', { fg = colors.hex_FD3E6A })
                hl(0, 'Macro', { fg = colors.hex_FD3E6A })
                hl(0, 'PreCondit', { fg = colors.hex_FD3E6A })
                hl(0, 'Type', { fg = colors.hex_E20342 })
                hl(0, 'StorageClass', { fg = colors.hex_E20342 })
                hl(0, 'Structure', { fg = colors.hex_E20342 })
                hl(0, 'Typedef', { fg = colors.hex_E20342 })
                hl(0, 'Special', { fg = colors.hex_04C5F0 })
                hl(0, 'SpecialChar', { fg = colors.hex_04C5F0 })
                hl(0, 'Tag', { fg = colors.hex_9147a8 })
                hl(0, 'Delimiter', { fg = colors.hex_c8e967 })
                hl(0, 'SpecialComment', { fg = colors.hex_6C032C, italic = true, bold = true })
                hl(0, 'Debug', { fg = colors.hex_f93d3b })
                hl(0, 'Underlined', { underline = true })
                hl(0, 'Error', { fg = colors.hex_f93d3b, bold = true })
                hl(0, 'Todo', { fg = colors.hex_04C5F0, bold = true })

                -- UI elements
                hl(0, 'StatusLine', { fg = colors.hex_14B9B5, bg = colors.hex_1a1520 })
                hl(0, 'StatusLineNC', { fg = colors.hex_9147a8, bg = colors.hex_1a1520 })
                hl(0, 'TabLine', { fg = colors.hex_9147a8, bg = colors.hex_000000 })
                hl(0, 'TabLineFill', { bg = colors.hex_000000 })
                hl(0, 'TabLineSel', { fg = colors.hex_14B9B5, bg = colors.hex_0e091d })
                hl(0, 'Pmenu', { fg = colors.hex_14B9B5, bg = colors.hex_1a1520 })
                hl(0, 'PmenuSel', { fg = colors.hex_0e091d, bg = colors.hex_14B9B5, bold = true })
                hl(0, 'PmenuSbar', { bg = colors.hex_1a1520 })
                hl(0, 'PmenuThumb', { bg = colors.hex_E20342 })
                hl(0, 'WildMenu', { fg = colors.hex_0e091d, bg = colors.hex_14B9B5 })
                hl(0, 'VertSplit', { fg = colors.hex_9147a8 })
                hl(0, 'WinSeparator', { fg = colors.hex_9147a8 })
                hl(0, 'Folded', { fg = colors.hex_9147a8, bg = colors.hex_1a1520 })
                hl(0, 'FoldColumn', { fg = colors.hex_FD3E6A, bg = colors.hex_0e091d })
                hl(0, 'SignColumn', { fg = colors.hex_E20342, bg = colors.hex_0e091d })
                hl(0, 'ColorColumn', { bg = colors.hex_1a1520 })

                -- Diff highlighting
                hl(0, 'DiffAdd', { fg = colors.hex_FF7F41, bg = colors.hex_061F23 })
                hl(0, 'DiffChange', { fg = colors.hex_04C5F0, bg = colors.hex_061F23 })
                hl(0, 'DiffDelete', { fg = colors.hex_f93d3b, bg = colors.hex_061F23 })
                hl(0, 'DiffText', { fg = colors.hex_A8D61F, bg = colors.hex_0C3F45, bold = true })

                -- Git signs
                hl(0, 'GitSignsAdd', { fg = colors.hex_FF7F41 })
                hl(0, 'GitSignsChange', { fg = colors.hex_04C5F0 })
                hl(0, 'GitSignsDelete', { fg = colors.hex_f93d3b })

                -- Diagnostic highlights
                hl(0, 'DiagnosticError', { fg = colors.hex_f93d3b })
                hl(0, 'DiagnosticWarn', { fg = colors.hex_04C5F0 })
                hl(0, 'DiagnosticInfo', { fg = colors.hex_ffbe74 })
                hl(0, 'DiagnosticHint', { fg = colors.hex_FD3E6A })
                hl(0, 'DiagnosticUnderlineError', { undercurl = true, sp = colors.hex_f93d3b })
                hl(0, 'DiagnosticUnderlineWarn', { undercurl = true, sp = colors.hex_04C5F0 })
                hl(0, 'DiagnosticUnderlineInfo', { undercurl = true, sp = colors.hex_ffbe74 })
                hl(0, 'DiagnosticUnderlineHint', { undercurl = true, sp = colors.hex_FD3E6A })

                -- LSP highlights
                hl(0, 'LspReferenceText', { bg = colors.hex_092F34 })
                hl(0, 'LspReferenceRead', { bg = colors.hex_092F34 })
                hl(0, 'LspReferenceWrite', { bg = colors.hex_092F34, underline = true })

                -- Treesitter highlights
                hl(0, '@variable', { fg = colors.hex_14B9B5 })
                hl(0, '@variable.builtin', { fg = colors.hex_ffbe74 })
                hl(0, '@variable.parameter', { fg = colors.hex_11AEB3 })
                hl(0, '@variable.member', { fg = colors.hex_7cd699 })
                hl(0, '@constant', { fg = colors.hex_ffbe74 })
                hl(0, '@constant.builtin', { fg = colors.hex_ffbe74 })
                hl(0, '@constant.macro', { fg = colors.hex_04C5F0 })
                hl(0, '@module', { fg = colors.hex_E20342 })
                hl(0, '@module.builtin', { fg = colors.hex_E20342 })
                hl(0, '@label', { fg = colors.hex_E20342 })
                hl(0, '@string', { fg = colors.hex_FF7F41 })
                hl(0, '@string.escape', { fg = colors.hex_04C5F0 })
                hl(0, '@string.special', { fg = colors.hex_04C5F0 })
                hl(0, '@string.regexp', { fg = colors.hex_FD3E6A })
                hl(0, '@character', { fg = colors.hex_FF7F41 })
                hl(0, '@character.special', { fg = colors.hex_04C5F0 })
                hl(0, '@boolean', { fg = colors.hex_ffbe74 })
                hl(0, '@number', { fg = colors.hex_ffbe74 })
                hl(0, '@number.float', { fg = colors.hex_ffbe74 })
                hl(0, '@type', { fg = colors.hex_E20342 })
                hl(0, '@type.builtin', { fg = colors.hex_E20342 })
                hl(0, '@type.definition', { fg = colors.hex_E20342 })
                hl(0, '@attribute', { fg = colors.hex_FD3E6A })
                hl(0, '@property', { fg = colors.hex_7cd699 })
                hl(0, '@function', { fg = colors.hex_7cd699 })
                hl(0, '@function.builtin', { fg = colors.hex_7cd699 })
                hl(0, '@function.call', { fg = colors.hex_7cd699 })
                hl(0, '@function.macro', { fg = colors.hex_FD3E6A })
                hl(0, '@function.method', { fg = colors.hex_7cd699 })
                hl(0, '@function.method.call', { fg = colors.hex_7cd699 })
                hl(0, '@constructor', { fg = colors.hex_E20342 })
                hl(0, '@operator', { fg = colors.hex_c8e967 })
                hl(0, '@keyword', { fg = colors.hex_9147a8 })
                hl(0, '@keyword.coroutine', { fg = colors.hex_9147a8 })
                hl(0, '@keyword.function', { fg = colors.hex_9147a8 })
                hl(0, '@keyword.operator', { fg = colors.hex_9147a8 })
                hl(0, '@keyword.import', { fg = colors.hex_FD3E6A })
                hl(0, '@keyword.conditional', { fg = colors.hex_9147a8 })
                hl(0, '@keyword.repeat', { fg = colors.hex_9147a8 })
                hl(0, '@keyword.return', { fg = colors.hex_9147a8 })
                hl(0, '@keyword.exception', { fg = colors.hex_f93d3b })
                hl(0, '@comment', { fg = colors.hex_6C032C, italic = true })
                hl(0, '@comment.documentation', { fg = colors.hex_6C032C, italic = true })
                hl(0, '@punctuation', { fg = colors.hex_c8e967 })
                hl(0, '@punctuation.bracket', { fg = colors.hex_c8e967 })
                hl(0, '@punctuation.delimiter', { fg = colors.hex_c8e967 })
                hl(0, '@punctuation.special', { fg = colors.hex_04C5F0 })
                hl(0, '@tag', { fg = colors.hex_9147a8 })
                hl(0, '@tag.attribute', { fg = colors.hex_E20342 })
                hl(0, '@tag.delimiter', { fg = colors.hex_c8e967 })

                -- Telescope
                hl(0, 'TelescopeBorder', { fg = colors.hex_9147a8 })
                hl(0, 'TelescopePromptBorder', { fg = colors.hex_E20342 })
                hl(0, 'TelescopeResultsBorder', { fg = colors.hex_FF7F41 })
                hl(0, 'TelescopePreviewBorder', { fg = colors.hex_ffbe74 })
                hl(0, 'TelescopeSelection', { fg = colors.hex_0e091d, bg = colors.hex_14B9B5, bold = true })
                hl(0, 'TelescopeMatching', { fg = colors.hex_9147a8, bold = true })

                -- Neo-tree
                hl(0, 'NeoTreeNormal', { fg = colors.hex_14B9B5, bg = colors.hex_0e091d })
                hl(0, 'NeoTreeDirectoryName', { fg = colors.hex_E20342 })
                hl(0, 'NeoTreeDirectoryIcon', { fg = colors.hex_FF7F41 })
                hl(0, 'NeoTreeFileName', { fg = colors.hex_14B9B5 })
                hl(0, 'NeoTreeFileIcon', { fg = colors.hex_c8e967 })
                hl(0, 'NeoTreeIndentMarker', { fg = colors.hex_9147a8 })
                hl(0, 'NeoTreeRootName', { fg = colors.hex_04C5F0, bold = true })
                hl(0, 'NeoTreeGitModified', { fg = colors.hex_04C5F0 })
                hl(0, 'NeoTreeGitAdded', { fg = colors.hex_c8e967 })
                hl(0, 'NeoTreeGitDeleted', { fg = colors.hex_f93d3b })

                -- Terminal colors (matching theme palette)
                vim.g.terminal_color_0 = '#061F23'  -- Very dark teal-blue
                vim.g.terminal_color_1 = '#E20342'  -- Bright red
                vim.g.terminal_color_2 = '#FF7F41'  -- Bright orange
                vim.g.terminal_color_3 = '#04C5F0'  -- Bright cyan-blue
                vim.g.terminal_color_4 = '#ffbe74'  -- Light orange-yellow
                vim.g.terminal_color_5 = '#FD3E6A'  -- Vibrant pink-red
                vim.g.terminal_color_6 = '#7cd699'  -- Light blue-green
                vim.g.terminal_color_7 = '#A8D61F'  -- Bright yellow-green
                vim.g.terminal_color_8 = '#0C3F45'  -- Dark muted blue-green
                vim.g.terminal_color_9 = '#f93d3b'  -- Vibrant red
                vim.g.terminal_color_10 = '#FF7F41' -- Bright orange
                vim.g.terminal_color_11 = '#ffbe74' -- Light orange-yellow
                vim.g.terminal_color_12 = '#dd66ff' -- Bright magenta-purple
                vim.g.terminal_color_13 = '#9147a8' -- Dark purple
                vim.g.terminal_color_14 = '#ff99dd' -- Light pink
                vim.g.terminal_color_15 = '#ffffff' -- Pure white

                -- Create autocmd to reapply tabline colors after colorscheme changes
                vim.api.nvim_create_autocmd("ColorScheme", {
                    pattern = "aetheria",
                    callback = function()
                        vim.api.nvim_set_hl(0, 'TabLine', { fg = '#9147a8', bg = '#000000' })
                        vim.api.nvim_set_hl(0, 'TabLineFill', { bg = '#000000' })
                        vim.api.nvim_set_hl(0, 'TabLineSel', { fg = '#14B9B5', bg = '#0e091d' })
                    end,
                })
            end,
        },
    },
}
