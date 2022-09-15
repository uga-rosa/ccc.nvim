---@class HexPicker: ColorPicker
local HexPicker = {
    pattern = "#(%x%x)(%x%x)(%x%x)",
}

---@param s string
---@return integer start
---@return integer end_
---@return integer R
---@return integer G
---@return integer B
---@overload fun(self: HexPicker, s: string): nil
function HexPicker:parse_color(s)
    local start, end_, cap1, cap2, cap3 = s:find(self.pattern)
    if start == nil then
        ---@diagnostic disable-next-line
        return nil
    end
    local R, G, B = tonumber(cap1, 16), tonumber(cap2, 16), tonumber(cap3, 16)
    return start, end_, R, G, B
end

return HexPicker
