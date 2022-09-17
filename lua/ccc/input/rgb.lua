local ColorInput = require("ccc.input")

---@class RgbInput: ColorInput
local RgbInput = setmetatable({
    name = "RGB",
    max = { 255, 255, 255 },
    min = { 0, 0, 0 },
    delta = { 1, 1, 1 },
    bar_name = { "R", "G", "B" },
}, { __index = ColorInput })

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
