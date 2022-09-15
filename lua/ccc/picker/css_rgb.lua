---@class CssRgbPicker: ColorPicker
local CssRgbPicker = {
    pattern = "rgb%((%d+),%s*(%d+),%s*(%d+)%)",
}

---@param s string
---@return integer start
---@return integer end_
---@return integer R
---@return integer G
---@return integer B
---@overload fun(self: CssRgbPicker, s: string): nil
function CssRgbPicker:parse_color(s)
    local start, end_, cap1, cap2, cap3 = s:find(self.pattern)
    if start == nil then
        ---@diagnostic disable-next-line
        return nil
    end
    local R, G, B = tonumber(cap1, 10), tonumber(cap2, 10), tonumber(cap3, 10)
    return start, end_, R, G, B
end

return CssRgbPicker
