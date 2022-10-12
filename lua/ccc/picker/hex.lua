local config = require("ccc.config")
local utils = require("ccc.utils")
local parse = require("ccc.utils.parse")

---@class HexPicker: ColorPicker
local HexPicker = {}

function HexPicker:init()
    if self.pattern then
        return
    end
    -- #RRGGBBAA
    -- #RRGGBB
    -- #RGBA
    -- #RGB
    self.pattern = {
        "#(%x%x)(%x%x)(%x%x)(%x%x)",
        "#(%x%x)(%x%x)(%x%x)",
        "#(%x)(%x)(%x)(%x)",
        "#(%x)(%x)(%x)",
    }
    local ex_pat = config.get("exclude_pattern")
    self.exclude_pattern = utils.expand_template(ex_pat.hex, self.pattern)
end

---@param s string
---@param init? integer
---@return integer? start
---@return integer? end_
---@return number[]? RGB
---@return number? alpha
function HexPicker:parse_color(s, init)
    self:init()
    init = vim.F.if_nil(init, 1)
    -- The shortest patten is 4 characters like `#fff`
    while init <= #s - 3 do
        local start, end_, cap1, cap2, cap3, cap4
        for _, pat in ipairs(self.pattern) do
            start, end_, cap1, cap2, cap3, cap4 = s:find(pat, init)
            if start then
                break
            end
        end
        if not (start and end_ and cap1 and cap2 and cap3) then
            return
        end
        local R = parse.hex(cap1)
        local G = parse.hex(cap2)
        local B = parse.hex(cap3)
        if R and G and B then
            if not utils.is_excluded(self.exclude_pattern, s, init, start, end_) then
                local A = parse.hex(cap4)
                return start, end_, { R, G, B }, A
            end
        end
        init = end_ + 1
    end
end

return HexPicker
