local ColorInput = require("ccc.input")
local convert = require("ccc.utils.convert")

---@class OkhslInput: ColorInput
local OkhsvInput = setmetatable({
    name = "OKHSV",
    max = { 360, 1, 1 },
    min = { 0, 0, 0 },
    delta = { 1, 0.01, 0.01 },
    bar_name = { "H", "S", "V" },
}, { __index = ColorInput })

---@param n number
---@param i integer
---@return string
function OkhsvInput.format(n, i)
    if i > 1 then
        n = n * 100
    end
    return ("%6d"):format(n)
end

---@param RGB number[]
---@return number[] OKHSV
function OkhsvInput.from_rgb(RGB)
    return convert.rgb2okhsv(RGB)
end

---@param OKHSV number[]
---@return number[] RGB
function OkhsvInput.to_rgb(OKHSV)
    return convert.okhsv2rgb(OKHSV)
end

return OkhsvInput
