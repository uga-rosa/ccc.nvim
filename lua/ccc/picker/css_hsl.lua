local convert = require("ccc.utils.convert")

---@class CssHslPicker: ColorPicker
local CssHslPicker = {
    pattern = "hsl%((%d+),%s*(%d+)%%,%s*(%d+)%%%)",
}

---@param s string
---@return integer start
---@return integer end_
---@return number[] RGB
---@overload fun(self: CssHslPicker, s: string): nil
function CssHslPicker.parse_color(s)
    local start, end_, cap1, cap2, cap3 = s:find(CssHslPicker.pattern)
    if start == nil then
        ---@diagnostic disable-next-line
        return
    end
    local HSL = vim.tbl_map(tonumber, { cap1, cap2, cap3 })
    local RGB = convert.hsl2rgb(HSL)
    return start, end_, RGB
end

return CssHslPicker
