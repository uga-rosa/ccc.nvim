local sa = require("ccc.utils.safe_array")

---@class CssRgbPicker: ColorPicker
local CssRgbPicker = {
    pattern = "rgb%((%d+),%s*(%d+),%s*(%d+)%)",
}

---@param s string
---@return integer start
---@return integer end_
---@return integer[] RGB
---@overload fun(self: CssRgbPicker, s: string): nil
function CssRgbPicker.parse_color(s)
    local start, end_, cap1, cap2, cap3 = s:find(CssRgbPicker.pattern)
    if start == nil then
        ---@diagnostic disable-next-line
        return nil
    end
    local RGB = sa.new({ cap1, cap2, cap3 }):map(tonumber):unpack()
    return start, end_, RGB
end

return CssRgbPicker
