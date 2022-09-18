local sa = require("ccc.utils.safe_array")

---@class CssRgbPicker: ColorPicker
local CssRgbPicker = {}

---@param s string
---@param init? integer
---@return integer start
---@return integer end_
---@return number[] RGB
---@return number alpha
---@overload fun(s: string): nil
function CssRgbPicker.parse_color(s, init)
    init = init or 1
    local start, end_, cap1, cap2, cap3, cap4, A
    -- no transparent
    start, end_, cap1, cap2, cap3 = s:find("rgb%((%d+),(%d+),(%d+)%)", init)
    if start == nil then
        start, end_, cap1, cap2, cap3, cap4 = s:find("rgb%((%d+),(%d+),(%d+),(%d+)%%%)", init)
        if start == nil then
            ---@diagnostic disable-next-line
            return nil
        end
        A = tonumber(cap4) / 100
    end
    local RGB = sa.new({ cap1, cap2, cap3 })
        :map(function(n)
            return tonumber(n) / 255
        end)
        :unpack()
    return start, end_, RGB, A
end

return CssRgbPicker
