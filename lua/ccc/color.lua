local utils = require("ccc.utils")
local config = require("ccc.config")

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
    local new = setmetatable({ input_mode = input_mode }, { __index = Color })

    local default_color = config.get("default_color")
    local recognized, v1, v2, v3 = utils.parse_color(default_color)
    if recognized == nil then
        error("Invalid default color: " .. default_color)
    end
    ---@cast v1 integer

    new:set(input_mode, recognized, v1, v2, v3)
    return new
end

---@param input_mode input_mode
---@param value_mode input_mode
---@param v1 integer
---@param v2 integer
---@param v3 integer
function Color:set(input_mode, value_mode, v1, v2, v3)
    local R, G, B, H, S, L
    if value_mode == "RGB" then
        R, G, B = v1, v2, v3
    else
        H, S, L = v1, v2, v3
    end

    if input_mode == "RGB" then
        if not (R and G and B) then
            R, G, B = utils.hsl2rgb(H, S, L)
        end
        self:set_rgb(R, G, B)
    else
        if not (H and S and L) then
            H, S, L = utils.rgb2hsl(R, G, B)
        end
        self:set_hsl(H, S, L)
    end
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
    self:set_hsl(utils.rgb2hsl(self:get_rgb()))
    self.input_mode = "HSL"
end

function Color:hsl2rgb()
    self:set_rgb(utils.hsl2rgb(self:get_hsl()))
    self.input_mode = "RGB"
end

---@param v1? integer
---@param v2? integer
---@param v3? integer
---@param mode? input_mode
---@return string
function Color:hex_str(v1, v2, v3, mode)
    local R, G, B
    if v1 and v2 and v3 then
        if mode == "RGB" then
            R, G, B = v1, v2, v3
        else
            R, G, B = utils.hsl2rgb(v1, v2, v3)
        end
    else
        if self.input_mode == "RGB" then
            R, G, B = self:get_rgb()
        else
            R, G, B = utils.hsl2rgb(self:get_hsl())
        end
    end
    return ("#%02x%02x%02x"):format(R, G, B)
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
    elseif output_mode == "HEX" then
        return self:hex_str()
    end
    error("Invalid mode: " .. output_mode)
end

return Color
