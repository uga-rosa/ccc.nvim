local config = require("ccc.config")
local utils = require("ccc.utils")
local convert = require("ccc.utils.convert")
local parse = require("ccc.utils.parse")
local pattern = require("ccc.utils.pattern")

---@class CssOklabPicker: ColorPicker
local CssOklabPicker = {}

function CssOklabPicker:init()
    if self.pattern then
        return
    end
    self.pattern = pattern.create(
        "oklab( [<per-num>|none]  [<per-num>|none]  [<per-num>|none] %[/ [<alpha-value>|none]]? )"
    )
    local ex_pat = config.get("exclude_pattern")
    self.exclude_pattern = utils.expand_template(ex_pat.css_oklab, pattern)
end

---@param s string
---@param init? integer
---@return integer? start
---@return integer? end_
---@return RGB?
---@return Alpha?
function CssOklabPicker:parse_color(s, init)
    self:init()
    init = vim.F.if_nil(init, 1)
    -- The shortest patten is 12 characters like `oklab(0 0 0)`
    while init <= #s - 11 do
        local start, end_, cap1, cap2, cap3, cap4 = pattern.find(s, self.pattern, init)
        if not (start and end_ and cap1 and cap2 and cap3) then
            return
        end
        local L = parse.percent(cap1)
        local a = parse.percent(cap2, 0.4)
        local b = parse.percent(cap3, 0.4)
        if utils.valid_range(L, 0, 1) and utils.valid_range({ a, b }, -0.4, 0.4) then
            if not utils.is_excluded(self.exclude_pattern, s, init, start, end_) then
                local RGB = convert.oklab2rgb({ L, a, b })
                local A = parse.alpha(cap4)
                return start, end_, RGB, A
            end
        end
        init = end_ + 1
    end
end

return CssOklabPicker
