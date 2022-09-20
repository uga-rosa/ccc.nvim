local config = require("ccc.config")
local utils = require("ccc.utils")

---@class HexPicker: ColorPicker
local HexPicker = {}

---@param cap string
---@return number?
local function cap2rgb(cap)
    if #cap == 1 then
        cap = cap .. cap
    end
    local x = tonumber(cap, 16)
    if x and 0 <= x and x <= 255 then
        return x / 255
    end
end

---@param s string
---@param init? integer
---@return integer? start
---@return integer? end_
---@return integer[]? RGB
function HexPicker.parse_color(s, init)
    init = vim.F.if_nil(init, 1)
    -- The shortest patten is 4 characters like `#fff`
    while init <= #s - 3 do
        local start, end_, cap1, cap2, cap3
        start, end_, cap1, cap2, cap3 = s:find("#(%x%x)(%x%x)(%x%x)", init)
        if start == nil then
            start, end_, cap1, cap2, cap3 = s:find("#(%x)(%x)(%x)", init)
        end
        if start == nil then
            return
        end
        local R = cap2rgb(cap1)
        local G = cap2rgb(cap2)
        local B = cap2rgb(cap3)
        if R and G and B then
            local ex_patten = config.get("exclude_pattern")
            if not utils.is_excluded(ex_patten.hex, s, init, start, end_) then
                return start, end_, { R, G, B }
            end
        end
        init = end_ + 1
    end
end

return HexPicker
