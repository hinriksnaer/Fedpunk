-- Automatically reload colorscheme when theme.lua changes
-- This enables dynamic theme switching without restarting Neovim

local theme_file = vim.fn.stdpath("config") .. "/lua/plugins/theme.lua"

-- Watch the theme file for changes
local function watch_theme_file()
  local uv = vim.loop
  local handle = uv.new_fs_event()

  if not handle then
    vim.notify("Failed to create file watcher for theme.lua", vim.log.levels.WARN)
    return
  end

  -- Start watching the parent directory (watching symlinks directly doesn't work reliably)
  local watch_path = vim.fn.fnamemodify(theme_file, ":h")

  uv.fs_event_start(
    handle,
    watch_path,
    { watch_entry = false },
    vim.schedule_wrap(function(err, filename, events)
      if err then
        return
      end

      -- Check if the changed file is theme.lua
      if filename == "theme.lua" then
        -- Longer delay to ensure file write is complete
        vim.defer_fn(function()
          -- Temporarily unset the flag so we can read the actual theme content
          local saved_flag = vim.g.lazyvim_configured
          vim.g.lazyvim_configured = false

          -- Reload the theme configuration
          local ok, theme_spec = pcall(dofile, theme_file)

          -- Restore the flag
          vim.g.lazyvim_configured = saved_flag

          if ok and theme_spec and type(theme_spec) == "table" then
            -- Find and apply the colorscheme
            for _, spec in ipairs(theme_spec) do
              if type(spec) == "table" and spec.opts and spec.opts.colorscheme then
                local colorscheme = spec.opts.colorscheme
                local current_theme = vim.g.colors_name

                -- Handle string colorscheme (e.g., "tokyonight")
                if type(colorscheme) == "string" and colorscheme ~= "" then
                  pcall(vim.cmd, "colorscheme " .. colorscheme)
                  if current_theme ~= colorscheme then
                    vim.notify("Theme switched to: " .. colorscheme, vim.log.levels.INFO)
                  end
                -- Handle function colorscheme (e.g., custom fedpunk themes)
                elseif type(colorscheme) == "function" then
                  local success = pcall(colorscheme)
                  if success then
                    local new_theme = vim.g.colors_name or "custom"
                    if current_theme ~= new_theme then
                      vim.notify("Theme switched to: " .. new_theme, vim.log.levels.INFO)
                    end
                  end
                end

                return
              end
            end
          end
        end, 300)
      end
    end)
  )
end

-- Function to manually reload theme (useful as fallback)
local function reload_theme()
  -- Temporarily unset the flag so we can read the actual theme content
  local saved_flag = vim.g.lazyvim_configured
  vim.g.lazyvim_configured = false

  local ok, theme_spec = pcall(dofile, theme_file)

  -- Restore the flag
  vim.g.lazyvim_configured = saved_flag

  if ok and theme_spec and type(theme_spec) == "table" then
    for _, spec in ipairs(theme_spec) do
      if type(spec) == "table" and spec.opts and spec.opts.colorscheme then
        local colorscheme = spec.opts.colorscheme

        if type(colorscheme) == "string" and colorscheme ~= "" then
          pcall(vim.cmd, "colorscheme " .. colorscheme)
          vim.notify("Theme reloaded: " .. colorscheme, vim.log.levels.INFO)
        elseif type(colorscheme) == "function" then
          local success = pcall(colorscheme)
          if success then
            local theme_name = vim.g.colors_name or "custom"
            vim.notify("Theme reloaded: " .. theme_name, vim.log.levels.INFO)
          end
        end
        return true
      end
    end
  end
  vim.notify("Failed to reload theme", vim.log.levels.ERROR)
  return false
end

-- Create user command for manual theme reload
vim.api.nvim_create_user_command("ReloadTheme", reload_theme, {
  desc = "Manually reload the current theme from theme.lua",
})

-- Track last theme by file modification time and size
local last_mtime = 0
local last_size = 0

-- Check if theme file has changed (by modification time and size)
local function check_theme_changed()
  local stat = vim.loop.fs_stat(theme_file)
  if stat then
    if stat.mtime.sec ~= last_mtime or stat.size ~= last_size then
      last_mtime = stat.mtime.sec
      last_size = stat.size
      return true
    end
  end
  return false
end

-- Auto-reload theme when gaining focus (catches missed file events)
local focus_timer = nil
vim.api.nvim_create_autocmd({ "FocusGained" }, {
  callback = function()
    if focus_timer then
      focus_timer:stop()
      focus_timer:close()
    end

    focus_timer = vim.loop.new_timer()
    focus_timer:start(
      100,
      0,
      vim.schedule_wrap(function()
        if check_theme_changed() then
          reload_theme()
        end
        focus_timer:close()
        focus_timer = nil
      end)
    )
  end,
})

-- Start watching after Neovim is fully loaded
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Initialize last file stats
    local stat = vim.loop.fs_stat(theme_file)
    if stat then
      last_mtime = stat.mtime.sec
      last_size = stat.size
    end

    -- Load the current theme on startup
    vim.defer_fn(function()
      reload_theme()
    end, 100)

    -- Start file watcher
    vim.defer_fn(watch_theme_file, 500)
  end,
})

return {}
