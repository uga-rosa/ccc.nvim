local config = require("ccc.config")
local utils = require("ccc.utils")
local parse = require("ccc.utils.parse")
local pattern = require("ccc.utils.pattern")

---@class CssRgbPicker: ColorPicker
local CssRgbPicker = {}

function CssRgbPicker:init()
    if self.pattern then
        return
    end
    self.pattern = {
        pattern.create(
            "rgba?( [<number>|none]  [<number>|none]  [<number>|none] %[/ [<alpha-value>|none]]? )"
        ),
        pattern.create(
            "rgba?( [<percentage>|none]  [<percentage>|none]  [<percentage>|none] %[/ [<alpha-value>|none]]? )"
        ),
        pattern.create(
            "rgba?( [<number>|none] , [<number>|none] , [<number>|none] %[, [<alpha-value>|none]]? )"
        ),
        pattern.create(
            "rgba?( [<percentage>|none] , [<percentage>|none] , [<percentage>|none] %[, [<alpha-value>|none]]? )"
        ),
    }
    local ex_pat = config.get("exclude_pattern")
    self.exclude_pattern = utils.expand_template(ex_pat.css_rgb, self.pattern)
end

---@param s string
---@param init? integer
---@return integer? start
---@return integer? end_
---@return RGB?
---@return Alpha?
function CssRgbPicker:parse_color(s, init)
    self:init()
    init = vim.F.if_nil(init, 1)
    -- The shortest patten is 10 characters like `rgb(0 0 0)`
    while init < #s - 9 do
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
        local R = parse.percent(cap1, 255, true)
        local G = parse.percent(cap2, 255, true)
        local B = parse.percent(cap3, 255, true)
        if utils.valid_range({ R, G, B }, 0, 1) then
            if not utils.is_excluded(self.exclude_pattern, s, init, start, end_) then
                local A = parse.alpha(cap4)
                return start, end_, { R, G, B }, A
            end
        end
        init = end_ + 1
    end
end

return CssRgbPicker
