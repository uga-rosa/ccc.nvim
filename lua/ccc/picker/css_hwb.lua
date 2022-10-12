local config = require("ccc.config")
local utils = require("ccc.utils")
local convert = require("ccc.utils.convert")
local parse = require("ccc.utils.parse")
local pattern = require("ccc.utils.pattern")

---@class CssHwbPicker: ColorPicker
local CssHwbPicker = {}

function CssHwbPicker:init()
    if self.pattern then
        return
    end
    self.pattern = pattern.create(
        "hwb( [<hue>|none]  [<percentage>|none]  [<percentage>|none]%[ / [<alpha-value>|none]]? )"
    )
    local ex_pat = config.get("exclude_pattern")
    self.exclude_pattern = utils.expand_template(ex_pat.css_hsl, pattern)
end

---@param s string
---@param init? integer
---@return integer? start
---@return integer? end_
---@return RGB?
---@return Alpha?
function CssHwbPicker:parse_color(s, init)
    self:init()
    init = vim.F.if_nil(init, 1)
    -- The shortest patten is 12 characters like `hwb(0 0% 0%)`
    while init <= #s - 11 do
        local start, end_, cap1, cap2, cap3, cap4 = pattern.find(s, self.pattern, init)
        if not (start and end_ and cap1 and cap2 and cap3) then
            return
        end
        local H = parse.hue(cap1)
        local W = parse.percent(cap2)
        local B = parse.percent(cap3)
        if H and W and B then
            if not utils.is_excluded(self.exclude_pattern, s, init, start, end_) then
                local RGB = convert.hsl2rgb({ H, W, B })
                local A = parse.percent(cap4)
                return start, end_, RGB, A
            end
        end
        init = end_ + 1
    end
end

return CssHwbPicker
