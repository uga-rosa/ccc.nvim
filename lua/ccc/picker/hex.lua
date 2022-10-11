local config = require("ccc.config")
local utils = require("ccc.utils")
local parse = require("ccc.utils.parse")

---@class HexPicker: ColorPicker
local HexPicker = {}

-- #RRGGBBAA
-- #RRGGBB
-- #RGBA
-- #RGB
local pattern = {
    "#(%x%x)(%x%x)(%x%x)(%x%x)",
    "#(%x%x)(%x%x)(%x%x)",
    "#(%x)(%x)(%x)(%x)",
    "#(%x)(%x)(%x)",
}
local exclude_pattern

---@param s string
---@param init? integer
---@return integer? start
---@return integer? end_
---@return number[]? RGB
---@return number? alpha
function HexPicker.parse_color(s, init)
    init = vim.F.if_nil(init, 1)
    if exclude_pattern == nil then
        local ex_pat = config.get("exclude_pattern")
        exclude_pattern = utils.expand_template(ex_pat.hex, pattern)
    end
    -- The shortest patten is 4 characters like `#fff`
    while init <= #s - 3 do
        local start, end_, cap1, cap2, cap3, cap4
        for _, pat in ipairs(pattern) do
            start, end_, cap1, cap2, cap3, cap4 = s:find(pat, init)
            if start then
                break
            end
        end
        if start == nil then
            return
        end
        local R = parse.hex(cap1)
        local G = parse.hex(cap2)
        local B = parse.hex(cap3)
        if R and G and B then
            if not utils.is_excluded(exclude_pattern, s, init, start, end_) then
                local A
                if cap4 then
                    A = parse.hex(cap4)
                end
                return start, end_, { R, G, B }, A
            end
        end
        init = end_ + 1
    end
end

return HexPicker
