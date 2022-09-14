local utils = require("ccc.utils")

---@class Color
---@field R integer
---@field G integer
---@field B integer
local Color = {}

function Color.new()
    local new = setmetatable({
        R = 0,
        G = 0,
        B = 0,
    }, { __index = Color })
    return new
end

---@return integer R
---@return integer G
---@return integer B
function Color:get_rgb()
    return self.R, self.G, self.B
end

---@param R integer
---@param G integer
---@param B integer
function Color:set_rgb(R, G, B)
    self.R, self.G, self.B = R, G, B
end

---@return integer H
---@return integer S
---@return integer L
function Color:get_hsl()
    return utils.rgb2hsl(self.R, self.G, self.B)
end

---@param H integer
---@param S integer
---@param L integer
function Color:set_hsl(H, S, L)
    self.R, self.G, self.B = utils.hsl2rgb(H, S, L)
end

---@param int integer
---@return string
local function to_hex(int)
    return string.format("%02x", int)
end

---@return string
function Color:colorcode()
    return "#" .. to_hex(self.R) .. to_hex(self.G) .. to_hex(self.B)
end

---@return string
function Color:rgb_str()
    return ("rgb(%s,%s,%s)"):format(self:get_rgb())
end

---@return string
function Color:hsl_str()
    return ("hsl(%s,%s%%,%s%%)"):format(self:get_hsl())
end

---@param output_mode mode
---@return string
function Color:output(output_mode)
    if output_mode == "RGB" then
        return self:rgb_str()
    elseif output_mode == "HSL" then
        return self:hsl_str()
    elseif output_mode == "ColorCode" then
        return self:colorcode()
    end
    error("Invalid mode: " .. output_mode)
end

return Color
