local api = require("ccc.utils.api")

local Convert = {}

function Convert.toggle()
  local opts = require("ccc.config").options

  local line = vim.api.nvim_get_current_line()
  local row, cursor_col = api.get_cursor()
  -- to 1-indexed column
  cursor_col = cursor_col + 1

  for _, v in ipairs(opts.convert) do
    local picker, output = v[1], v[2]

    local init = 1
    while true do
      local start_col, end_col, rgb, alpha = picker:parse_color(line, init)
      if not (start_col and end_col and rgb) then
        break
      elseif start_col <= cursor_col and end_col >= cursor_col then
        vim.api.nvim_buf_set_text(0, row, start_col - 1, row, end_col, { output.str(rgb, alpha) })
        return
      else
        init = end_col + 1
      end
    end
  end
end

return Convert
