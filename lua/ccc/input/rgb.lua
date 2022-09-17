local ColorInput = require("ccc.input")

---@class RgbInput: ColorInput
local RgbInput = setmetatable({
    name = "RGB",
    max = { 1, 1, 1 },
    min = { 0, 0, 0 },
    delta = { 1 / 255, 1 / 255, 1 / 255 },
    bar_name = { "R", "G", "B" },
}, { __index = ColorInput })

---@param n number
---@return string
function RgbInput.format(n)
    return ("%6d"):format(n * 255)
end

---@param RGB number[]
---@return number[] RGB
function RgbInput.from_rgb(RGB)
    return RGB
end

---@param RGB number[]
---@return number[] RGB
function RgbInput.to_rgb(RGB)
    return RGB
end

return RgbInput
