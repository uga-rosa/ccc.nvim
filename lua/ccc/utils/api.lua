-- (0, 0) indexed, end-exclusive
local M = {}

---@return integer row 0-indexed
---@return integer col 0-indexed
function M.get_cursor()
  local cursor = vim.api.nvim_win_get_cursor(0)
  return cursor[1] - 1, cursor[2]
end

---@param row integer 0-indexed
---@param col integer 0-indexed
function M.set_cursor(row, col)
  vim.api.nvim_win_set_cursor(0, { row + 1, col })
end

---@param bufnr integer
---@param range ccc.Range { start_row, start_col, end_row, end_col }; 0-indexed, Only end_col is exclusive.
---@param text string | string[]
function M.set_text(bufnr, range, text)
  if type(text) == "string" then
    text = { text }
  end
  vim.api.nvim_buf_set_text(bufnr, range[1], range[2], range[3], range[4], text)
end

---@param bufnr integer
---@param start_row integer 0-indexed
---@param end_row integer 0-indexed, exclusive
---@param lines string[]
function M.set_lines(bufnr, start_row, end_row, lines)
  vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
  vim.api.nvim_buf_set_lines(bufnr, start_row, end_row, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
end

---@param bufnr integer
---@param ns_id integer
---@param range ccc.Range
---@param hl_group string
---@param hl_def? vim.api.keyset.highlight
function M.set_hl(bufnr, ns_id, range, hl_group, hl_def)
  if hl_def then
    vim.api.nvim_set_hl(ns_id, hl_group, hl_def)
  end
  vim.api.nvim_buf_set_extmark(bufnr, ns_id, range[1], range[2], {
    strict = false, -- prevents #126
    hl_group = hl_group,
    end_row = range[3],
    end_col = range[4],
  })
end

---@param bufnr integer
---@param ns_id integer
---@param pos ccc.Position
---@param mark string
---@param virt_pos "inline" | "eol"
---@param hl_group string
---@param hl_def? vim.api.keyset.highlight
function M.virtual_hl(bufnr, ns_id, pos, mark, virt_pos, hl_group, hl_def)
  if hl_def then
    vim.api.nvim_set_hl(ns_id, hl_group, hl_def)
  end
  vim.api.nvim_buf_set_extmark(bufnr, ns_id, pos[1], pos[2], {
    virt_text = { { mark, hl_group } },
    virt_text_pos = virt_pos,
  })
end

---@param bufnr integer
---@param row integer 0-index
---@return integer length
function M.line_length(bufnr, row)
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
  return vim.api.nvim_strwidth(line)
end

return M
