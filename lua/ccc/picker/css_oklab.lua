local utils = require("ccc.utils")
local convert = require("ccc.utils.convert")
local parse = require("ccc.utils.parse")
local pattern = require("ccc.utils.pattern")

---@class ccc.ColorPicker.CssOklab: ccc.ColorPicker
---@field pattern string
local CssOklabPicker = {}

function CssOklabPicker:init()
  if self.pattern then
    return
  end
  self.pattern =
    pattern.create("oklab( [<per-num>|none]  [<per-num>|none]  [<per-num>|none] %[/ [<alpha-value>|none]]? )")
end

---@param s string
---@param init? integer
---@return integer? start_col
---@return integer? end_col
---@return RGB? rgb
---@return Alpha? alpha
function CssOklabPicker:parse_color(s, init)
  self:init()
  init = init or 1
  -- The shortest patten is 12 characters like `oklab(0 0 0)`
  while init <= #s - 11 do
    local start_col, end_col, cap1, cap2, cap3, cap4 = pattern.find(s, self.pattern, init)
    if not (start_col and end_col and cap1 and cap2 and cap3) then
      return
    end
    local L = parse.percent(cap1)
    local a = parse.percent(cap2, 0.4)
    local b = parse.percent(cap3, 0.4)
    if utils.valid_range(L, 0, 1) and utils.valid_range({ a, b }, -0.4, 0.4) then
      local RGB = convert.oklab2rgb({ L, a, b })
      local A = parse.alpha(cap4)
      return start_col, end_col, RGB, A
    end
    init = end_col + 1
  end
end

return CssOklabPicker
