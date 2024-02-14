local M = {}

function M.select(cmd)
  local opts = require("ccc.config").options
  ---@type integer?, integer?, RGB?, Alpha?
  local start, end_
  if opts.lsp then
    start, end_ = require("ccc.handler.lsp"):pick()
  end
  if start == nil then
    start, end_ = require("ccc.handler.picker").pick()
  end
  if not (start and end_) then
    return
  end

  local row = require("ccc.utils").row()
  vim.api.nvim_win_set_cursor(0, { row, start - 1 })
  vim.cmd("normal! " .. cmd)
  vim.api.nvim_win_set_cursor(0, { row, end_ - 1 })
end

return M
