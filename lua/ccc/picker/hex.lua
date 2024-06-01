local parse = require("ccc.utils.parse")
local pattern = require("ccc.utils.pattern")

---@class ccc.ColorPicker.Hex: ccc.ColorPicker
---@field pattern string[]
local HexPicker = {
  -- #RRGGBB
  -- #RRGGBBAA
  -- #RGB
  -- #RGBA
  pattern = {
    [=[\v%(^|[^[:keyword:]])\zs#(\x\x)(\x\x)(\x\x)>]=],
    [=[\v%(^|[^[:keyword:]])\zs#(\x\x)(\x\x)(\x\x)(\x\x)>]=],
    [=[\v%(^|[^[:keyword:]])\zs#(\x)(\x)(\x)>]=],
    [=[\v%(^|[^[:keyword:]])\zs#(\x)(\x)(\x)(\x)>]=],
  },
}

---@param s string
---@param init? integer
---@return integer? start_col
---@return integer? end_col
---@return number[]? rgb
---@return number? alpha
function HexPicker:parse_color(s, init)
  init = init or 1
  -- The shortest patten is 4 characters like `#fff`
  while init <= #s - 3 do
    local start_col, end_col, cap1, cap2, cap3, cap4
    for _, pat in ipairs(self.pattern) do
      start_col, end_col, cap1, cap2, cap3, cap4 = pattern.find(s, pat, init)
      if start_col then
        break
      end
    end
    if not (start_col and end_col and cap1 and cap2 and cap3) then
      return
    end
    local r = parse.hex(cap1)
    local g = parse.hex(cap2)
    local b = parse.hex(cap3)
    if r and g and b then
      local A = parse.hex(cap4)
      return start_col, end_col, { r, g, b }, A
    end
    init = end_col + 1
  end
end

return HexPicker
