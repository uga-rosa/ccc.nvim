local parse = require("ccc.utils.parse")

---@param str string
---@return RGB?
local parse_hex = function(str)
  local r, g, b = str:match("(%x%x)(%x%x)(%x%x)")
  r, g, b = parse.hex(r), parse.hex(g), parse.hex(b)
  if r and g and b then
    return { r, g, b }
  end
end

---@class TrailingWhitespacePicker: ColorPicker
---@field ft2color table<string, RGB>
---@field filter table<string, boolean>
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
    local rgb = parse_hex(hex)
    if rgb then
      palette[ft] = rgb
    else
      vim.notify("[ccc] Invalid color representation: " .. hex)
    end
  end
  local default_color = parse_hex(opts.default_color) or parse_hex(default.default_color)
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
---@return RGB?
---@return Alpha?
function TrailingWhitespacePicker:parse_color(s, init)
  init = vim.F.if_nil(init, 1)
  local ft = vim.bo.filetype
  if not self.filter[ft] then
    return
  end
  local start, end_ = s:find("%s+$", init)
  if start then
    return start, end_, self.ft2color[ft]
  end
end

return TrailingWhitespacePicker.new
