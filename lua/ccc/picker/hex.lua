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

local pattern = {
    "#(%x%x)(%x%x)(%x%x)",
    "#(%x)(%x)(%x)",
}
local exclude_pattern

---@param s string
---@param init? integer
---@return integer? start
---@return integer? end_
---@return integer[]? RGB
function HexPicker.parse_color(s, init)
    init = vim.F.if_nil(init, 1)
    if exclude_pattern == nil then
        local ex_pat = config.get("exclude_pattern")
        exclude_pattern = utils.expand_template(ex_pat.hex, pattern)
    end
    -- The shortest patten is 4 characters like `#fff`
    while init <= #s - 3 do
        local start, end_, cap1, cap2, cap3
        for _, pat in ipairs(pattern) do
            start, end_, cap1, cap2, cap3 = s:find(pat, init)
            if start then
                break
            end
        end
        if start == nil then
            return
        end
        local R = cap2rgb(cap1)
        local G = cap2rgb(cap2)
        local B = cap2rgb(cap3)
        if R and G and B then
            if not utils.is_excluded(exclude_pattern, s, init, start, end_) then
                return start, end_, { R, G, B }
            end
        end
        init = end_ + 1
    end
end

return HexPicker
