local utils = require("ccc.utils")
local convert = require("ccc.utils.convert")
local parse = require("ccc.utils.parse")
local pattern = require("ccc.utils.pattern")

---@class ccc.ColorPicker.CssOklch: ccc.ColorPicker
---@field pattern string
local CssOklchPicker = {}

function CssOklchPicker:init()
  if self.pattern then
    return
  end
  self.pattern = pattern.create("oklch( [<per-num>|none]  [<per-num>|none]  [<hue>|none] %[/ [<alpha-value>|none]]? )")
end

---@param s string
---@param init? integer
---@return integer? start_col
---@return integer? end_col
---@return RGB? rgb
---@return Alpha? alpha
function CssOklchPicker:parse_color(s, init)
  self:init()
  init = init or 1
  -- The shortest patten is 10 characters like `lch(0 0 0)`
  while init <= #s - 9 do
    local start_col, end_col, cap1, cap2, cap3, cap4 = pattern.find(s, self.pattern, init)
    if not (start_col and end_col and cap1 and cap2 and cap3) then
      return
    end
    local L = parse.percent(cap1, 1)
    local C = parse.percent(cap2, 0.4)
    local H = parse.hue(cap3)
    if utils.valid_range(L, 0, 1) and utils.valid_range(C, 0, 0.4) and H then
      local RGB = convert.oklch2rgb({ L, C, H })
      local A = parse.alpha(cap4)
      return start_col, end_col, RGB, A
    end
    init = end_col + 1
  end
end

return CssOklchPicker
