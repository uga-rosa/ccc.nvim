local ColorInput = require("ccc.input")
local hsluv = require("ccc.utils.hsluv")
local utils = require("ccc.utils")
local sa = require("ccc.utils.safe_array")

---@class HSLuvInput: ColorInput
local HSLuvInput = setmetatable({
    name = "HSLuv",
    max = { 360, 100, 100 },
    min = { 0, 0, 0 },
    delta = { 1, 1, 1 },
    bar_name = { "H", "S", "L" },
}, { __index = ColorInput })

---@param RGB integer[]
---@return integer[] HSL
function HSLuvInput.from_rgb(RGB)
    return hsluv.rgb_to_hsluv(RGB)
end

---@param HSL integer[]
---@return integer[] RGB
function HSLuvInput.to_rgb(HSL)
    return sa.new(hsluv.hsluv_to_rgb(HSL))
        :map(function(v)
            return utils.round(v * 255)
        end)
        :unpack()
end

return HSLuvInput
