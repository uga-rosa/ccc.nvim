local config = require("ccc.config")
local utils = require("ccc.utils")
local convert = require("ccc.utils.convert")
local parse = require("ccc.utils.parse")
local pattern = require("ccc.utils.pattern")

---@class CssHslPicker: ColorPicker
local CssHslPicker = {}

function CssHslPicker:init()
    if self.pattern then
        return
    end
    self.pattern = {
        pattern.create(
            "hsla?( [<hue>|none]  [<percentage>|none]  [<percentage>|none] %[/ [<alpha-value>|none]]? )"
        ),
        pattern.create("hsla?( [<hue>] , [<percentage>] , [<percentage>] %[, [<alpha-value>]]? )"),
    }
    local ex_pat = config.get("exclude_pattern")
    self.exclude_pattern = utils.expand_template(ex_pat.css_hsl, self.pattern)
end

---@param s string
---@param init? integer
---@return integer? start
---@return integer? end_
---@return RGB?
---@return Alpha?
function CssHslPicker:parse_color(s, init)
    self:init()
    init = vim.F.if_nil(init, 1)
    -- The shortest patten is 12 characters like `hsl(0 0% 0%)`
    while init <= #s - 11 do
        local start, end_, cap1, cap2, cap3, cap4
        for _, pat in ipairs(self.pattern) do
            start, end_, cap1, cap2, cap3, cap4 = pattern.find(s, pat, init)
            if start then
                break
            end
        end
        if not (start and end_ and cap1 and cap2 and cap3) then
            return
        end
        local H = parse.hue(cap1)
        local S = parse.percent(cap2)
        local L = parse.percent(cap3)
        if H and S and L then
            if not utils.is_excluded(self.exclude_pattern, s, init, start, end_) then
                local RGB = convert.hsl2rgb({ H, S, L })
                local A = parse.alpha(cap4)
                return start, end_, RGB, A
            end
        end
        init = end_ + 1
    end
end

return CssHslPicker
