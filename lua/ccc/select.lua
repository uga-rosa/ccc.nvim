local api = require("ccc.utils.api")

local M = {}

function M.select(cmd)
  local opts = require("ccc.config").options
  ---@type integer?, integer?, RGB?, Alpha?
  local start_col, end_col
  if opts.lsp then
    start_col, end_col = require("ccc.handler.lsp"):pick()
  end
  if start_col == nil then
    start_col, end_col = require("ccc.handler.picker").pick()
  end
  if not (start_col and end_col) then
    return
  end

  local row = api.get_cursor()
  api.set_cursor(row, start_col - 1)
  vim.cmd("normal! " .. cmd)
  api.set_cursor(row, end_col - 1)
end

return M
