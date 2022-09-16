local ColorInput = require("ccc.input")
local convert = require("ccc.utils.convert")
local utils = require("ccc.utils")

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
    local Linear = convert.rgb2linear(RGB)
    local XYZ = convert.linear2xyz(Linear)
    return convert.xyz2lab(XYZ)
end

---@param Lab integer[]
---@return integer[] RGB
function LabInput.to_rgb(Lab)
    local XYZ = convert.lab2xyz(Lab)
    local Linear = convert.xyz2linear(XYZ)
    local RGB = convert.linear2rgb(Linear)
    return vim.tbl_map(function(x)
        return utils.fix_overflow(x, 0, 255)
    end, RGB)
end

return LabInput
