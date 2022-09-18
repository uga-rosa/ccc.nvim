local convert = require("ccc.utils.convert")

---@class CssHslPicker: ColorPicker
local CssHslPicker = {}

---@param s string
---@return integer start
---@return integer end_
---@return number[] RGB
---@return number alpha
---@overload fun(s: string): nil
function CssHslPicker.parse_color(s)
    local start, end_, cap1, cap2, cap3, cap4, A
    start, end_, cap1, cap2, cap3 = s:find("hsl%((%d+),%s*(%d+)%%,%s*(%d+)%%%)")
    if start == nil then
        start, end_, cap1, cap2, cap3, cap4 =
            s:find("hsl%((%d+),%s*(%d+)%%,%s*(%d+)%%,%s*(%d+)%%%)")
        if start == nil then
            ---@diagnostic disable-next-line
            return
        end
        A = tonumber(cap4) / 100
    end
    local H = tonumber(cap1)
    local S = tonumber(cap2) / 100
    local L = tonumber(cap3) / 100
    local RGB = convert.hsl2rgb({ H, S, L })
    return start, end_, RGB, A
end

return CssHslPicker
