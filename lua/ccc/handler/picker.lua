local utils = require("ccc.utils")
local hl = require("ccc.handler.highlight")

---@class ccc.PickerHandler
local PickerHandler = {}

---@return integer? start_col 1-index
---@return integer? end_col 1-index, included
---@return RGB? RGB
---@return Alpha? Alpha
---@return ccc.ColorInput? recognized_input
---@return ccc.ColorOutput? recognized_output
function PickerHandler.pick()
  local opts = require("ccc.config").options
  local line = vim.api.nvim_get_current_line()
  local cursor_col = utils.col()

  local init = 1
  while init <= #line do
    local start, end_, RGB, A, input, output
    for _, picker in ipairs(opts.pickers) do
      local s_, e_, rgb, a = picker:parse_color(line, init)
      if s_ and e_ and rgb and (start == nil or s_ < start) then
        start, end_, RGB, A = s_, e_, rgb, a

        local pattern = utils.oc(opts.recognize, "pattern", picker) or {}
        if opts.recognize.input then
          input = pattern[1]
        end
        if opts.recognize.output then
          output = pattern[2]
        end
      end
    end
    if start == nil then
      break
    end
    if start <= cursor_col and cursor_col <= end_ then
      return start, end_, RGB, A, input, output
    end
    init = end_ + 1
  end
end

---@param bufnr integer
---@param start_line integer 0-based
---@param end_line integer 0-based
---@return ccc.hl_info[]
function PickerHandler:info_in_range(bufnr, start_line, end_line)
  local opts = require("ccc.config").options
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, true)

  local infos = {}
  for i, line in ipairs(lines) do
    local row = start_line + i - 1
    for _, picker in ipairs(opts.pickers) do
      local init = 1
      while init <= #line do
        local start, end_, RGB, _, hl_def = picker:parse_color(line, init)
        if (RGB or hl_def) and end_ then
          table.insert(infos, {
            range = utils.range(row, start - 1, row, end_),
            hl_name = hl.ensure_hl_name(RGB, hl_def),
          })
          init = end_ + 1
        else
          break
        end
      end
    end
  end
  return infos
end

return PickerHandler