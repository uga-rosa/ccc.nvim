local ColorInput = require("ccc.input")
local convert = require("ccc.utils.convert")

---@class LabInput: ColorInput
local LabInput = setmetatable({
    name = "Lab",
    max = { 100, 128, 128 },
    min = { 0, -128, -128 },
    delta = { 1, 1, 1 },
    bar_name = { "L*", "a*", "b*" },
}, { __index = ColorInput })

---@param RGB integer[]
---@return integer[] Lab
function LabInput.from_rgb(RGB)
    return convert.rgb2lab(RGB)
end

---@param Lab integer[]
---@return integer[] RGB
function LabInput.to_rgb(Lab)
    return convert.lab2rgb(Lab)
end

return LabInput
