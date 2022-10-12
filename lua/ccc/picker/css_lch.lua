local config = require("ccc.config")
local utils = require("ccc.utils")
local convert = require("ccc.utils.convert")
local parse = require("ccc.utils.parse")
local pattern = require("ccc.utils.pattern")

---@class CssLchPicker: ColorPicker
local CssLchPicker = {}

function CssLchPicker:init()
    if self.pattern then
        return
    end
    self.pattern = pattern.create(
        "lch( [<per-num>|none]  [<per-num>|none]  [<hue>|none] %[/ [<alpha-value>|none]]? )"
    )
    local ex_pat = config.get("exclude_pattern")
    self.exclude_pattern = utils.expand_template(ex_pat.css_lch, pattern)
end

---@param s string
---@param init? integer
---@return integer? start
---@return integer? end_
---@return RGB?
---@return Alpha?
function CssLchPicker:parse_color(s, init)
    self:init()
    init = vim.F.if_nil(init, 1)
    -- The shortest patten is 10 characters like `lch(0 0 0)`
    while init <= #s - 9 do
        local start, end_, cap1, cap2, cap3, cap4 = pattern.find(s, self.pattern, init)
        if not (start and end_ and cap1 and cap2 and cap3) then
            return
        end
        local L = parse.percent(cap1, 100)
        local C = parse.percent(cap2, 150)
        local H = parse.hue(cap3)
        if L and C and H then
            if not utils.is_excluded(self.exclude_pattern, s, init, start, end_) then
                L = L * 100
                C = C * 150
                local RGB = convert.lch2rgb({ L, C, H })
                local A = parse.percent(cap4)
                return start, end_, RGB, A
            end
        end
        init = end_ + 1
    end
end

return CssLchPicker
