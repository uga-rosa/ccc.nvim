local utils = require("ccc.utils")

---@class ccc.ColorPicker.TrailingWhiteSpace: ccc.ColorPicker
---@field ft2color table<string, RGB>
---@field filter table<string, boolean>
local TrailingWhitespacePicker = {}
TrailingWhitespacePicker.__index = TrailingWhitespacePicker

---@class ccc.Option.TrailingWhitespace
---@field palette table<string, string> Keys are filetypes, values are colors (hex)
---@field default_color string Hex
---@field enable string[]|true List of filetypes for which highlighting is enabled or true.
---@field disable string[]|fun(bufnr: number): boolean Used only when enable is true. List of filetypes to disable highlighting or a function that returns true when you want to disable it.
local default = {
  palette = {},
  default_color = "#db7093",
  enable = true,
  disable = {},
}

local contains = vim.list_contains or vim.tbl_contains

---@param opts? ccc.Option.TrailingWhitespace
---@return ccc.ColorPicker.TrailingWhiteSpace
function TrailingWhitespacePicker.new(opts)
  opts = vim.tbl_extend("keep", opts or {}, default)

  local palette = {}
  for ft, hex in pairs(opts.palette) do
    palette[ft] = hex
  end
  local ft2color = setmetatable(palette, {
    __index = function()
      return opts.default_color
    end,
  })

  local filter
  if opts.enable == true then
    if type(opts.disable) == "table" then
      function filter(bufnr)
        local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
        return not contains(opts.disable, ft)
      end
    elseif type(opts.disable) == "function" then
      function filter(bufnr)
        return not opts.disable(bufnr)
      end
    end
  else
    function filter(bufnr)
      local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
      return contains(opts.enable, ft)
    end
  end

  local self = setmetatable({
    ft2color = ft2color,
    filter = filter,
  }, TrailingWhitespacePicker)

  vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function(ev)
      require("ccc.highlighter"):update(ev.buf, 0, -1)
    end,
  })

  return self
end

---@param s string
---@param init? integer
---@param bufnr? integer
---@return integer? start_col
---@return integer? end_col
---@return nil rgb
---@return nil alpha
---@return vim.api.keyset.highlight? hl_def
function TrailingWhitespacePicker:parse_color(s, init, bufnr)
  init = init or 1
  bufnr = utils.ensure_bufnr(bufnr)
  if not self.filter(bufnr) or vim.fn.mode() == "i" then
    return
  end
  local start_col, end_col = s:find("%s+$", init or 1)
  if start_col and end_col then
    local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
    local hex = self.ft2color[ft]
    return start_col, end_col, nil, nil, { bg = hex }
  end
end

return TrailingWhitespacePicker.new
