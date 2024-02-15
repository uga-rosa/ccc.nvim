local utils = require("ccc.utils")
local convert = require("ccc.utils.convert")
local parse = require("ccc.utils.parse")
local pattern = require("ccc.utils.pattern")

---@class ccc.ColorPicker.CssHwb: ccc.ColorPicker
---@field pattern string
local CssHwbPicker = {}

function CssHwbPicker:init()
  if self.pattern then
    return
  end
  self.pattern =
    pattern.create("hwb( [<hue>|none]  [<percentage>|none]  [<percentage>|none] %[/ [<alpha-value>|none]]? )")
end

---@param s string
---@param init? integer
---@return integer? start_col
---@return integer? end_col
---@return RGB? rgb
---@return Alpha? alpha
function CssHwbPicker:parse_color(s, init)
  self:init()
  init = init or 1
  -- The shortest patten is 12 characters like `hwb(0 0% 0%)`
  while init <= #s - 11 do
    local start_col, end_col, cap1, cap2, cap3, cap4 = pattern.find(s, self.pattern, init)
    if not (start_col and end_col and cap1 and cap2 and cap3) then
      return
    end
    local H = parse.hue(cap1)
    local W = parse.percent(cap2)
    local B = parse.percent(cap3)
    if H and utils.valid_range({ W, B }, 0, 1) then
      local RGB = convert.hwb2rgb({ H, W, B })
      local A = parse.alpha(cap4)
      return start_col, end_col, RGB, A
    end
    init = end_col + 1
  end
end

return CssHwbPicker
