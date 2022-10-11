local config = require("ccc.config")
local utils = require("ccc.utils")
local convert = require("ccc.utils.convert")
local parse = require("ccc.utils.parse")

---@class CssHslPicker: ColorPicker
local CssHslPicker = {}

local pattern = {
    "hsl%(%s*([%.%d]+[a-z]*)%s*,%s*([%.%d]+%%)%s*,%s*([%.%d]+%%)%s*%)",
    "hsla?%(%s*([%.%d]+[a-z]*)%s*,%s*([%.%d]+%%)%s*,%s*([%.%d]+%%)%s*,%s*([%.%d]+%%?)%s*%)",
    "hsl%(%s*([%.%d]+[a-z]*)%s+([%.%d]+%%)%s+([%.%d]+%%)%s*%)",
    "hsla?%(%s*([%.%d]+[a-z]*)%s+([%.%d]+%%)%s+([%.%d]+%%)%s*/%s*([%.%d]+%%?)%s*%)",
}
local exclude_pattern

---@param s string
---@param init? integer
---@return integer? start
---@return integer? end_
---@return RGB?
---@return Alpha?
function CssHslPicker.parse_color(s, init)
    init = vim.F.if_nil(init, 1)
    if exclude_pattern == nil then
        local ex_pat = config.get("exclude_pattern")
        exclude_pattern = utils.expand_template(ex_pat.css_hsl, pattern)
    end
    -- The shortest patten is 12 characters like `hsl(0 0% 0%)`
    while init <= #s - 11 do
        local start, end_, cap1, cap2, cap3, cap4
        for _, pat in ipairs(pattern) do
            start, end_, cap1, cap2, cap3, cap4 = s:find(pat, init)
            if start then
                break
            end
        end
        if start == nil then
            return
        end
        local H = parse.hue(cap1)
        local S = parse.percent(cap2)
        local L = parse.percent(cap3)
        if H and S and L then
            if not utils.is_excluded(exclude_pattern, s, init, start, end_) then
                local RGB = convert.hsl2rgb({ H, S, L })
                local A
                if cap4 then
                    A = parse.percent(cap4)
                end
                return start, end_, RGB, A
            end
        end
        init = end_ + 1
    end
end

return CssHslPicker
