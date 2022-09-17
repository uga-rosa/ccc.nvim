local sa = require("ccc.utils.safe_array")

---@class HexPicker: ColorPicker
local HexPicker = {
    pattern = "#(%x%x)(%x%x)(%x%x)",
}

---@param s string
---@return integer start
---@return integer end_
---@return integer[] RGB
---@overload fun(self: HexPicker, s: string): nil
function HexPicker.parse_color(s)
    local start, end_, cap1, cap2, cap3 = s:find(HexPicker.pattern)
    if start == nil then
        ---@diagnostic disable-next-line
        return nil
    end
    local RGB = sa.new({ cap1, cap2, cap3 })
        :map(function(c)
            return tonumber(c, 16) / 255
        end)
        :unpack()
    return start, end_, RGB
end

return HexPicker
