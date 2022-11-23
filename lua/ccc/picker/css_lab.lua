local config = require("ccc.config")
local utils = require("ccc.utils")
local convert = require("ccc.utils.convert")
local parse = require("ccc.utils.parse")
local pattern = require("ccc.utils.pattern")

---@class CssLabPicker: ColorPicker
local CssLabPicker = {}

function CssLabPicker:init()
  if self.pattern then
    return
  end
  self.pattern =
    pattern.create("lab( [<per-num>|none]  [<per-num>|none]  [<per-num>|none] %[/ [<alpha-value>|none]]? )")
  local ex_pat = config.get("exclude_pattern")
  self.exclude_pattern = utils.expand_template(ex_pat.css_lab, pattern)
end

---@param s string
---@param init? integer
---@return integer? start
---@return integer? end_
---@return RGB?
---@return Alpha?
function CssLabPicker:parse_color(s, init)
  self:init()
  init = vim.F.if_nil(init, 1)
  -- The shortest patten is 10 characters like `lab(0 0 0)`
  while init <= #s - 9 do
    local start, end_, cap1, cap2, cap3, cap4 = pattern.find(s, self.pattern, init)
    if not (start and end_ and cap1 and cap2 and cap3) then
      return
    end
    local L = parse.percent(cap1, 100)
    local a = parse.percent(cap2, 125)
    local b = parse.percent(cap3, 125)
    if utils.valid_range(L, 0, 100) and utils.valid_range({ a, b }, -125, 125) then
      if not utils.is_excluded(self.exclude_pattern, s, init, start, end_) then
        local RGB = convert.lab2rgb({ L, a, b })
        local A = parse.alpha(cap4)
        return start, end_, RGB, A
      end
    end
    init = end_ + 1
  end
end

return CssLabPicker
