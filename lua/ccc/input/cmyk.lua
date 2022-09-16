local ColorInput = require("ccc.input")
local utils = require("ccc.utils")

---@class HslInput: ColorInput
local CmykInput = setmetatable({
    name = "CMYK",
    max = { 100, 100, 100, 100 },
    min = { 0, 0, 0, 0 },
    delta = { 1, 1, 1, 1 },
    bar_name = { "C", "M", "Y", "K" },
}, { __index = ColorInput })

---@param v number
---@return string
function CmykInput.format(v)
    return ("%5d%%"):format(v)
end

---@param x number
---@return number
local function div255(x)
    return x / 2.55
end

---@param RGB integer[]
---@return integer[] CMYK
function CmykInput.from_rgb(RGB)
    local C, M, Y, K
    local R_, G_, B_ = unpack(vim.tbl_map(div255, RGB))
    K = 100 - utils.max(R_, G_, B_)
    if K == 100 then
        return { 0, 0, 0, 100 }
    end
    C = (100 - R_ - K) / (100 - K) * 100
    M = (100 - G_ - K) / (100 - K) * 100
    Y = (100 - B_ - K) / (100 - K) * 100
    return { C, M, Y, K }
end

---@param CMYK integer[]
---@return integer[] RGB
function CmykInput.to_rgb(CMYK)
    local R, G, B
    local C, M, Y, K = unpack(CMYK)
    if K == 100 then
        return { 0, 0, 0 }
    end
    R = utils.round(0.0255 * (100 - C) * (100 - K))
    G = utils.round(0.0255 * (100 - M) * (100 - K))
    B = utils.round(0.0255 * (100 - Y) * (100 - K))
    return { R, G, B }
end

return CmykInput
