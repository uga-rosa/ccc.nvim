local ColorInput = require("ccc.input")
local utils = require("ccc.utils")

---@class HslInput: ColorInput
local CmykInput = setmetatable({
    name = "CMYK",
    max = { 1, 1, 1, 1 },
    min = { 0, 0, 0, 0 },
    delta = { 0.005, 0.005, 0.005, 0.005 },
    bar_name = { "C", "M", "Y", "K" },
}, { __index = ColorInput })

---@param n number
---@return string
function CmykInput.format(n)
    return ("%5.1f%%"):format(n * 100)
end

---@param x number
---@return number
local function div255(x)
    return x / 255
end

---@param RGB integer[]
---@return integer[] CMYK
function CmykInput.from_rgb(RGB)
    local C, M, Y, K
    local R_, G_, B_ = unpack(vim.tbl_map(div255, RGB))
    K = 1 - utils.max(R_, G_, B_)
    if K == 1 then
        return { 0, 0, 0, 1 }
    end
    C = (1 - R_ - K) / (1 - K)
    M = (1 - G_ - K) / (1 - K)
    Y = (1 - B_ - K) / (1 - K)
    return { C, M, Y, K }
end

---@param CMYK integer[]
---@return integer[] RGB
function CmykInput.to_rgb(CMYK)
    local R, G, B
    local C, M, Y, K = unpack(CMYK)
    if K == 1 then
        return { 0, 0, 0 }
    end
    R = utils.round(255 * (1 - C) * (1 - K))
    G = utils.round(255 * (1 - M) * (1 - K))
    B = utils.round(255 * (1 - Y) * (1 - K))
    return { R, G, B }
end

return CmykInput
