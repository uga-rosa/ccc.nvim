local config = require("ccc.config")
local utils = require("ccc.utils")

---@class CssRgbPicker: ColorPicker
local CssRgbPicker = {}

---@param cap string
---@return number?
local function cap2rgb(cap)
    local x
    if cap:sub(-1, -1) == "%" then
        x = tonumber(cap:sub(1, -2))
        if x == nil then
            return
        end
        x = x / 100
    else
        x = tonumber(cap)
        if x == nil then
            return
        end
        x = x / 255
    end
    if 0 <= x and x <= 1 then
        return x
    end
end

---@param cap? string
---@return number?
local function cap2alpha(cap)
    if cap == nil then
        return
    end
    local x
    if cap:sub(-1, -1) == "%" then
        x = tonumber(cap:sub(1, -2))
        if x == nil then
            return
        end
        x = x / 100
    else
        x = tonumber(cap)
    end
    if x and 0 <= x and x <= 1 then
        return x
    end
end

local pattern = {
    "rgb%(%s*([%.%d]+%%?)%s*,%s*([%.%d]+%%?)%s*,%s*([%.%d]+%%?)%s*%)",
    "rgba?%(%s*([%.%d]+%%?)%s*,%s*([%.%d]+%%?)%s*,%s*([%.%d]+%%?)%s*,%s*([%.%d]+%%?)%)",
    "rgb%(%s*([%.%d]+%%?)%s+([%.%d]+%%?)%s+([%.%d]+%%?)%s*%)",
    "rgba?%(%s*([%.%d]+%%?)%s+([%.%d]+%%?)%s+([%.%d]+%%?)%s*/%s*([%.%d]+%%?)%)",
}
local exclude_pattern

---@param s string
---@param init? integer
---@return integer? start
---@return integer? end_
---@return RGB?
---@return Alpha?
function CssRgbPicker.parse_color(s, init)
    init = vim.F.if_nil(init, 1)
    if exclude_pattern == nil then
        local ex_pat = config.get("exclude_pattern")
        exclude_pattern = utils.expand_template(ex_pat.css_rgb, pattern)
    end
    -- The shortest patten is 10 characters like `rgb(0,0,0)`
    while init < #s - 9 do
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
        local R = cap2rgb(cap1)
        local G = cap2rgb(cap2)
        local B = cap2rgb(cap3)
        if R and G and B then
            if not utils.is_excluded(exclude_pattern, s, init, start, end_) then
                local A = cap2alpha(cap4)
                return start, end_, { R, G, B }, A
            end
        end
        init = end_ + 1
    end
end

return CssRgbPicker
