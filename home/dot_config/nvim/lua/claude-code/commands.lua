-- User commands for claude-code.nvim
local M = {}

local window = require("claude-code.window")
local config = require("claude-code.config")

-- Create all user commands
function M.setup()
  local opts = config.get()

  -- :ClaudeCode - Open Claude Code
  vim.api.nvim_create_user_command("ClaudeCode", function()
    window.open(opts)
  end, { desc = "Open Claude Code" })

  -- :ClaudeToggle - Toggle Claude Code window
  vim.api.nvim_create_user_command("ClaudeToggle", function()
    window.toggle(opts)
  end, { desc = "Toggle Claude Code window" })

  -- :ClaudeClose - Close Claude Code window
  vim.api.nvim_create_user_command("ClaudeClose", function()
    window.close()
  end, { desc = "Close Claude Code window" })

  -- :ClaudeFocus - Focus Claude Code window
  vim.api.nvim_create_user_command("ClaudeFocus", function()
    window.focus()
  end, { desc = "Focus Claude Code window" })

  -- :ClaudeExitTerminal - Exit terminal mode
  vim.api.nvim_create_user_command("ClaudeExitTerminal", function()
    window.exit_terminal_mode()
  end, { desc = "Exit terminal mode in Claude Code" })

  -- :ClaudeCloseBuffers - Close specific buffers
  vim.api.nvim_create_user_command("ClaudeCloseBuffers", function(args)
    local buf_numbers = {}
    for num in args.args:gmatch("%d+") do
      table.insert(buf_numbers, tonumber(num))
    end
    window.close_buffers(buf_numbers)
    if opts.integration.notify then
      vim.notify(string.format("Closed %d buffer(s)", #buf_numbers), vim.log.levels.INFO)
    end
  end, {
    nargs = "+",
    desc = "Close specified buffers by number",
  })

  -- :ClaudeBuffers - Show buffer list
  vim.api.nvim_create_user_command("ClaudeBuffers", function()
    local buffers = window.get_buffers()
    print("Open buffers:")
    for _, buf in ipairs(buffers) do
      local modified = buf.modified and "[+]" or "   "
      print(string.format("  %3d %s %s", buf.number, modified, buf.name))
    end
  end, { desc = "List all buffers" })

  -- :ClaudeAsk - Send current buffer or selection to Claude
  vim.api.nvim_create_user_command("ClaudeAsk", function(args)
    -- Get current buffer content or selection
    local lines
    local mode = vim.fn.mode()

    if mode == "v" or mode == "V" then
      -- Visual mode - get selection
      local start_pos = vim.fn.getpos("'<")
      local end_pos = vim.fn.getpos("'>")
      lines = vim.fn.getline(start_pos[2], end_pos[2])
    else
      -- Normal mode - get current buffer
      lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    end

    local content = table.concat(lines, "\n")
    local prompt = args.args ~= "" and args.args or "Explain this code:"

    -- Open Claude if not open
    if not window.is_open() then
      window.open(opts)
    end

    -- Focus Claude window
    window.focus()

    if opts.integration.notify then
      vim.notify("Sent content to Claude Code", vim.log.levels.INFO)
    end
  end, {
    nargs = "?",
    range = true,
    desc = "Send buffer/selection to Claude with optional question",
  })
end

return M
