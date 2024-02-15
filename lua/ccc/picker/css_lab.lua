local utils = require("ccc.utils")
local convert = require("ccc.utils.convert")
local parse = require("ccc.utils.parse")
local pattern = require("ccc.utils.pattern")

---@class ccc.ColorPicker.CssLab: ccc.ColorPicker
---@field pattern string
local CssLabPicker = {}

function CssLabPicker:init()
  if self.pattern then
    return
  end
  self.pattern =
    pattern.create("lab( [<per-num>|none]  [<per-num>|none]  [<per-num>|none] %[/ [<alpha-value>|none]]? )")
end

---@param s string
---@param init? integer
---@return integer? start_col
---@return integer? end_col
---@return RGB? rgb
---@return Alpha? alpha
function CssLabPicker:parse_color(s, init)
  self:init()
  init = init or 1
  -- The shortest patten is 10 characters like `lab(0 0 0)`
  while init <= #s - 9 do
    local start_col, end_col, cap1, cap2, cap3, cap4 = pattern.find(s, self.pattern, init)
    if not (start_col and end_col and cap1 and cap2 and cap3) then
      return
    end
    local L = parse.percent(cap1, 100)
    local a = parse.percent(cap2, 125)
    local b = parse.percent(cap3, 125)
    if utils.valid_range(L, 0, 100) and utils.valid_range({ a, b }, -125, 125) then
      local RGB = convert.lab2rgb({ L, a, b })
      local A = parse.alpha(cap4)
      return start_col, end_col, RGB, A
    end
    init = end_col + 1
  end
end

return CssLabPicker
