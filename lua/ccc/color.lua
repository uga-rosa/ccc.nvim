local utils = require("ccc.utils")

---@class Color
---@field R integer
---@field G integer
---@field B integer
---@field H integer
---@field S integer
---@field L integer
---@field input_mode "RGB" | "HSL"
local Color = {}

---@param input_mode input_mode
---@return Color
function Color.new(input_mode)
    return setmetatable({
        R = 0,
        G = 0,
        B = 0,
        H = 0,
        S = 0,
        L = 0,
        input_mode = input_mode,
    }, { __index = Color })
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
    return self.H, self.S, self.L
end

---@param H integer
---@param S integer
---@param L integer
function Color:set_hsl(H, S, L)
    self.H, self.S, self.L = H, S, L
end

function Color:rgb2hsl()
    self.H, self.S, self.L = utils.rgb2hsl(self.R, self.G, self.B)
    self.input_mode = "HSL"
end

function Color:hsl2rgb()
    self.R, self.G, self.B = utils.hsl2rgb(self.H, self.S, self.L)
    self.input_mode = "RGB"
end

---@param int integer
---@return string
local function to_hex(int)
    return string.format("%02x", int)
end

---@return string
function Color:colorcode()
    local R, G, B = self:get_rgb()
    if self.input_mode == "HSL" then
        R, G, B = utils.hsl2rgb(self:get_hsl())
    end
    return "#" .. to_hex(R) .. to_hex(G) .. to_hex(B)
end

---@return string
function Color:rgb_str()
    local R, G, B = self:get_rgb()
    if self.input_mode == "HSL" then
        R, G, B = utils.hsl2rgb(self:get_hsl())
    end
    return ("rgb(%s,%s,%s)"):format(R, G, B)
end

---@return string
function Color:hsl_str()
    local H, S, L = self:get_hsl()
    if self.input_mode == "RGB" then
        H, S, L = utils.rgb2hsl(self:get_rgb())
    end
    return ("hsl(%s,%s%%,%s%%)"):format(H, S, L)
end

---@param output_mode output_mode
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
