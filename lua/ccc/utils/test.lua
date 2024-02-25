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
---@param lnum? integer 0-indexed
---@return string
function M.get_line(lnum)
  if lnum then
    return vim.api.nvim_buf_get_lines(0, lnum, lnum + 1, true)[1]
  else
    return vim.api.nvim_get_current_line()
  end
end

---Get lines from current buffer
---@param start_row integer 0-indexed
---@param end_row integer 0-indexed, exclusive
---@return string[]
function M.get_lines(start_row, end_row)
  return vim.api.nvim_buf_get_lines(0, start_row, end_row, true)
end

---@param start_row integer 0-indexed
---@param end_row integer 0-indexed, exclusive
---@param lines string[]
function M.set_lines(start_row, end_row, lines)
  vim.api.nvim_buf_set_lines(0, start_row, end_row, true, lines)
end

return M
