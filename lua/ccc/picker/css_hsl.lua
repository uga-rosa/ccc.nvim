local utils = require("ccc.utils")

---@class CssHslPicker: ColorPicker
local CssHslPicker = {
    pattern = "hsl%((%d+),%s*(%d+)%%,%s*(%d+)%%%)",
}

---@param s string
---@return integer start
---@return integer end_
---@return integer R
---@return integer G
---@return integer B
---@overload fun(self: CssHslPicker, s: string): nil
function CssHslPicker:parse_color(s)
    local start, end_, cap1, cap2, cap3 = s:find(self.pattern)
    if start == nil then
        ---@diagnostic disable-next-line
        return
    end
    local R, G, B = utils.hsl2rgb(tonumber(cap1, 10), tonumber(cap2, 10), tonumber(cap3, 10))
    return start, end_, R, G, B
end

return CssHslPicker
