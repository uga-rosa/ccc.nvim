local convert = require("ccc.utils.convert")

---@class CssHslPicker: ColorPicker
local CssHslPicker = {}

---@param cap string
---@return number?
local function cap2sl(cap)
    local x = tonumber(cap)
    if x and 0 <= x and x <= 100 then
        return x / 100
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

---@param s string
---@param init? integer
---@return integer? start
---@return integer? end_
---@return number[]? RGB
---@return number? alpha
function CssHslPicker.parse_color(s, init)
    init = vim.F.if_nil(init, 1)
    local start, end_, cap1, cap2, cap3, cap4
    start, end_, cap1, cap2, cap3 = s:find("hsl%(%s*(%d+)%s*,%s*(%d+)%%%s*,%s*(%d+)%%%s*%)", init)
    if start == nil then
        start, end_, cap1, cap2, cap3, cap4 =
            s:find("hsl%(%s*(%d+)%s*,%s*(%d+)%%%s*,%s*(%d+)%%%s*,%s*([%.%d]+%%?)%s*%)")
        if start == nil then
            return
        end
    end
    local H = tonumber(cap1)
    local S = cap2sl(cap2)
    local L = cap2sl(cap3)
    if H and S and L then
        local RGB = convert.hsl2rgb({ H, S, L })
        local A = cap2alpha(cap4)
        return start, end_, RGB, A
    end
end

return CssHslPicker
