local convert = require("ccc.utils.convert")
local ColorInput = require("ccc.input")

---@class XyzInput: ColorInput
local XyzInput = setmetatable({
    name = "XYZ",
    max = { 1, 1, 1},
    min = { 0, 0, 0 },
    delta = { 0.005, 0.005, 0.005 },
    bar_name = { "X", "Y", "Z" },
}, { __index = ColorInput })

function XyzInput.format(n)
    return ("%5.1f%%"):format(n * 100)
end

---@param RGB integer[]
---@return number[] XYZ
function XyzInput.from_rgb(RGB)
    return convert.linear2xyz(convert.rgb2linear(RGB))
end

---@param XYZ number[]
---@return integer[] RGB
function XyzInput.to_rgb(XYZ)
    local RGB = convert.linear2rgb(convert.xyz2linear(XYZ))
    for _, v in ipairs(RGB) do
        if v < 0 or 255 < v then
            return { 0, 0, 0 }
        end
    end
    return RGB
end

return XyzInput
