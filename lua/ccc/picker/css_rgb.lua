---@class CssRgbPicker: ColorPicker
local CssRgbPicker = {}

---@param cap string
---@return number?
local function cap2rgb(cap)
    local x
    if cap:sub(-1, -1) == "%" then
        x = tonumber(cap:sub(1, -2))
        if x == nil then
            return
        end
        x = x / 100
    else
        x = tonumber(cap)
        if x == nil then
            return
        end
        x = x / 255
    end
    if 0 <= x and x <= 1 then
        return x
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

---@param s string
---@param init? integer
---@return integer? start
---@return integer? end_
---@return number[]? RGB
---@return number? alpha
function CssRgbPicker.parse_color(s, init)
    init = vim.F.if_nil(init, 1)
    local start, end_, cap1, cap2, cap3, cap4
    start, end_, cap1, cap2, cap3 =
        s:find("rgb%(%s*(%d+%%?)%s*,%s*(%d+%%?)%s*,%s*(%d+%%?)%s*%)", init)
    if start == nil then
        start, end_, cap1, cap2, cap3, cap4 =
            s:find("rgba?%(%s*(%d+%%?)%s*,%s*(%d+%%?)%s*,%s*(%d+%%?)%s*,%s*([%.%d]+%%?)%)", init)
        if start == nil then
            return
        end
    end
    local R = cap2rgb(cap1)
    local G = cap2rgb(cap2)
    local B = cap2rgb(cap3)
    if R and G and B then
        local A = cap2alpha(cap4)
        return start, end_, { R, G, B }, A
    end
end

return CssRgbPicker
