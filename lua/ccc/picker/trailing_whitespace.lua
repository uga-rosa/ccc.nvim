---@class TrailingWhitespacePicker: ColorPicker
---@field ft2color table<string, RGB>
---@field filter table<string, boolean>
---@field inInsert boolean
local TrailingWhitespacePicker = {}

---@class TrailingWhitespaceConfig
---@field palette table<string, string> Keys are filetypes, values are colors (hex)
---@field default_color string Hex
---@field enable string[]|true List of filetypes for which highlighting is enabled or true.
---@field disable string[] Used only when enable is true. List of filetypes for which highlighting is disabled.
local default = {
  palette = {},
  default_color = "#db7093",
  enable = true,
  disable = {},
}

---@param opts? TrailingWhitespaceConfig
---@return TrailingWhitespacePicker
function TrailingWhitespacePicker.new(opts)
  opts = vim.tbl_extend("keep", opts or {}, default)

  local palette = {}
  for ft, hex in pairs(opts.palette) do
    palette[ft] = hex
  end
  local default_color = opts.default_color
  local ft2color = setmetatable(palette, {
    __index = function()
      return default_color
    end,
  })

  local filter = {}
  if opts.enable == true then
    setmetatable(filter, {
      __index = function()
        return true
      end,
    })
    for _, ft in ipairs(opts.disable) do
      filter[ft] = false
    end
  else
    for _, ft in ipairs(opts.enable) do
      filter[ft] = true
    end
    setmetatable(filter, {
      __index = function()
        return false
      end,
    })
  end

  return setmetatable({
    ft2color = ft2color,
    filter = filter,
  }, { __index = TrailingWhitespacePicker })
end

---@param s string
---@param init? integer
---@return integer? start
---@return integer? end_
---@return nil
---@return nil
---@return highlightDefinition?
function TrailingWhitespacePicker:parse_color(s, init)
  local ft = vim.bo.filetype
  if not self.filter[ft] then
    return
  end
  if vim.startswith(vim.fn.mode(), "i") then
    if not self.inInsert then
      local highlighter = require("ccc.highlighter").new()
      highlighter.pickers = { self }
      vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function(opts)
          highlighter:update_picker(opts.buf, 0, -1)
          self.inInsert = false
        end,
      })
      self.inInsert = true
    end
    return
  end
  local start, end_ = s:find("%s+$", init or 1)
  if start then
    local hex = self.ft2color[ft]
    return start, end_, nil, nil, { bg = hex }
  end
end

return TrailingWhitespacePicker.new
