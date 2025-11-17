-- Window and buffer management for claude-code.nvim
local M = {}

-- State
M.state = {
  win = nil, -- Window handle
  buf = nil, -- Buffer handle
  job_id = nil, -- Terminal job ID
}

-- Check if window is valid and open
function M.is_open()
  return M.state.win and vim.api.nvim_win_is_valid(M.state.win)
end

-- Get split command based on position
local function get_split_cmd(position, size)
  if position == "right" then
    return "vertical rightbelow " .. size .. "split"
  elseif position == "left" then
    return "vertical leftbelow " .. size .. "split"
  elseif position == "bottom" then
    return "horizontal rightbelow " .. size .. "split"
  elseif position == "top" then
    return "horizontal leftbelow " .. size .. "split"
  else
    return "vertical rightbelow " .. size .. "split"
  end
end

-- Create or focus the Claude Code window
function M.open(config)
  -- If already open, just focus it
  if M.is_open() then
    vim.api.nvim_set_current_win(M.state.win)
    return
  end

  -- Save current window
  local original_win = vim.api.nvim_get_current_win()

  -- Calculate size
  local size = (config.window.position == "right" or config.window.position == "left")
    and config.window.width
    or config.window.height

  -- Create split
  local split_cmd = get_split_cmd(config.window.position, size)
  vim.cmd(split_cmd)

  -- Create or reuse buffer
  if not M.state.buf or not vim.api.nvim_buf_is_valid(M.state.buf) then
    M.state.buf = vim.api.nvim_create_buf(false, true)
  end

  -- Set buffer in window
  vim.api.nvim_win_set_buf(0, M.state.buf)
  M.state.win = vim.api.nvim_get_current_win()

  -- Configure buffer
  vim.api.nvim_buf_set_option(M.state.buf, "bufhidden", "hide")
  vim.api.nvim_buf_set_option(M.state.buf, "buflisted", false)
  vim.api.nvim_buf_set_name(M.state.buf, "claude-code")

  -- Configure window
  if config.window.border ~= "none" then
    vim.api.nvim_win_set_option(M.state.win, "winhl", "Normal:Normal,FloatBorder:FloatBorder")
  end

  -- Start terminal if not already running
  if not M.state.job_id then
    local shell_cmd = config.terminal.shell
    -- Get current working directory from original window
    local cwd = vim.fn.getcwd(vim.api.nvim_win_get_number(original_win))

    -- Start terminal with pushd/popd to maintain directory
    local cmd = string.format("pushd '%s' && %s && popd", cwd, shell_cmd)
    M.state.job_id = vim.fn.termopen(cmd)

    -- Exit terminal mode if configured
    if config.terminal.start_in_normal_mode then
      vim.cmd("stopinsert")
    end
  end

  -- Set up buffer-local keymaps
  if config.auto_commands.close_with_q then
    vim.api.nvim_buf_set_keymap(
      M.state.buf,
      "n",
      "q",
      ":ClaudeClose<CR>",
      { noremap = true, silent = true }
    )
  end

  -- Set up autocommands for this buffer
  local group = vim.api.nvim_create_augroup("ClaudeCodeBuffer", { clear = true })

  -- Auto-close when buffer is deleted
  vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    buffer = M.state.buf,
    callback = function()
      M.state.win = nil
      M.state.buf = nil
      M.state.job_id = nil
    end,
  })

  return M.state.win
end

-- Close the Claude Code window
function M.close()
  if M.is_open() then
    vim.api.nvim_win_close(M.state.win, false)
    M.state.win = nil
  end
end

-- Toggle the Claude Code window
function M.toggle(config)
  if M.is_open() then
    M.close()
  else
    M.open(config)
  end
end

-- Focus the Claude Code window
function M.focus()
  if M.is_open() then
    vim.api.nvim_set_current_win(M.state.win)
  end
end

-- Exit terminal mode
function M.exit_terminal_mode()
  if M.is_open() then
    vim.api.nvim_set_current_win(M.state.win)
    -- Send <C-\><C-n> to exit terminal mode
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
  end
end

-- Close buffers by number
function M.close_buffers(buf_numbers)
  for _, buf_num in ipairs(buf_numbers) do
    if vim.api.nvim_buf_is_valid(buf_num) then
      vim.api.nvim_buf_delete(buf_num, { force = false })
    end
  end
end

-- Get buffer list
function M.get_buffers()
  local buffers = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      table.insert(buffers, {
        number = buf,
        name = vim.api.nvim_buf_get_name(buf),
        modified = vim.api.nvim_buf_get_option(buf, "modified"),
      })
    end
  end
  return buffers
end

return M
