local config = require("ccc.config")
local utils = require("ccc.utils")
local convert = require("ccc.utils.convert")

---@class CssHwbPicker: ColorPicker
local CssHwbPicker = {}

---@param cap string
---@return number?
local function cap2h(cap)
    local x
    if vim.endswith(cap, "deg") then
        cap = cap:sub(1, -4)
        x = tonumber(cap)
    elseif vim.endswith(cap, "grad") then
        cap = cap:sub(1, -5)
        x = tonumber(cap)
        if x then
            x = x / 400 * 360
        end
    elseif vim.endswith(cap, "rad") then
        cap = cap:sub(1, -4)
        x = tonumber(cap)
        if x then
            x = x / (2 * math.pi) * 360
        end
    elseif vim.endswith(cap, "turn") then
        cap = cap:sub(1, -5)
        x = tonumber(cap)
        if x then
            x = x * 360
        end
    else
        x = tonumber(cap)
    end
    return x
end

---@param cap string
---@return number?
local function cap2wb(cap)
    local x = tonumber(cap)
    if x and 0 <= x and x <= 100 then
        return x / 100
    end
end

---@param cap? string
---@return number?
local function cap2alpha(cap)
    if cap == nil then
        return
    end
    local x
    if cap:sub(-1, -1) == "%" then
        x = tonumber(cap:sub(1, -2))
        if x == nil then
            return
        end
        x = x / 100
    else
        x = tonumber(cap)
    end
    if x and 0 <= x and x <= 1 then
        return x
    end
end

local pattern = {
    "hwb%(%s*([%.%d]+[a-z]*)%s+([%.%d]+)%%%s+([%.%d]+)%%%s*%)",
    "hwb%(%s*([%.%d]+[a-z]*)%s+([%.%d]+)%%%s+([%.%d]+)%%%s*/%s*([%.%d]+%%?)%s*%)",
}
local exclude_pattern

---@param s string
---@param init? integer
---@return integer? start
---@return integer? end_
---@return RGB?
---@return Alpha?
function CssHwbPicker.parse_color(s, init)
    init = vim.F.if_nil(init, 1)
    if exclude_pattern == nil then
        local ex_pat = config.get("exclude_pattern")
        exclude_pattern = utils.expand_template(ex_pat.css_hsl, pattern)
    end
    -- The shortest patten is 12 characters like `hwb(0 0% 0%)`
    while init <= #s - 11 do
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
        local H = cap2h(cap1)
        local W = cap2wb(cap2)
        local B = cap2wb(cap3)
        if H and W and B then
            if not utils.is_excluded(exclude_pattern, s, init, start, end_) then
                local RGB = convert.hsl2rgb({ H, W, B })
                local A = cap2alpha(cap4)
                return start, end_, RGB, A
            end
        end
        init = end_ + 1
    end
end

return CssHwbPicker
