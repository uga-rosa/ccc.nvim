local M = {}

---@param a number
---@param b number
---@param limit number
---@return boolean
function M.near(a, b, limit)
  return math.abs(a - b) < limit
end

---Number of windows
---@return integer
function M.num_win()
  return vim.fn.winnr("$")
end

---Get line from current buffer
---@param lnum? integer 0-index
---@return string
function M.get_line(lnum)
  if lnum then
    return vim.api.nvim_buf_get_lines(0, lnum, lnum + 1, true)[1]
  else
    return vim.api.nvim_get_current_line()
  end
end

---Get lines from current buffer
---@param start integer 0-index
---@param end_ integer 0-index (exclusived)
---@return string[]
function M.get_lines(start, end_)
  return vim.api.nvim_buf_get_lines(0, start, end_, true)
end

return M
