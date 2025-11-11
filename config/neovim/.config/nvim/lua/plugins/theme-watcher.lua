-- Automatically reload colorscheme when theme.lua changes
-- This enables dynamic theme switching without restarting Neovim

return {
  {
    'LazyVim/LazyVim',
    opts = function()
      -- Path to the theme configuration file (symlinked by fedpunk-theme-set)
      local theme_file = vim.fn.stdpath 'config' .. '/lua/plugins/theme.lua'

      -- Watch the theme file for changes
      local function watch_theme_file()
        -- Use libuv file watcher
        local uv = vim.loop
        local handle = uv.new_fs_event()

        if not handle then
          vim.notify('Failed to create file watcher for theme.lua', vim.log.levels.WARN)
          return
        end

        -- Start watching the parent directory (watching symlinks directly doesn't work reliably)
        local watch_path = vim.fn.fnamemodify(theme_file, ':h')

        uv.fs_event_start(
          handle,
          watch_path,
          {},
          vim.schedule_wrap(function(err, filename, events)
            if err then
              return
            end

            -- Check if the changed file is theme.lua
            if filename == 'theme.lua' or events.rename then
              -- Small delay to ensure file write is complete
              vim.defer_fn(function()
                -- Reload the theme configuration
                local ok, theme_spec = pcall(dofile, theme_file)
                if ok and theme_spec then
                  -- Find and apply the colorscheme
                  for _, spec in ipairs(theme_spec) do
                    if spec.opts and spec.opts.colorscheme then
                      local colorscheme = spec.opts.colorscheme
                      -- Only reload if it's a different colorscheme
                      if vim.g.colors_name ~= colorscheme then
                        vim.cmd.colorscheme(colorscheme)
                        vim.notify('Theme switched to: ' .. colorscheme, vim.log.levels.INFO)
                      end
                      return
                    end
                  end
                end
              end, 100)
            end
          end)
        )
      end

      -- Start watching after Neovim is fully loaded
      vim.api.nvim_create_autocmd('VimEnter', {
        callback = function()
          -- Delay slightly to ensure everything is loaded
          vim.defer_fn(watch_theme_file, 500)
        end,
      })
    end,
  },
}
