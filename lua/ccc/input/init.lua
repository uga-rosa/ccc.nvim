local utils = require("ccc.utils")

---@class ColorInput
---@field name string
---@field max integer[]
---@field bar_name string[]
---@field v1 integer
---@field v2 integer
---@field v3 integer
---@field from_rgb fun(R: integer, G: integer, B: integer): v1: integer, v2: integer, v3: integer
---@field to_rgb fun(v1: integer, v2: integer, v3: integer): R: integer, G: integer, B: integer
local ColorInput = {}

function ColorInput:new()
    return setmetatable({}, { __index = self })
end

---@param v1 integer
---@param v2 integer
---@param v3 integer
function ColorInput:set(v1, v2, v3)
    self.v1, self.v2, self.v3 = v1, v2, v3
end

---@param R integer
---@param G integer
---@param B integer
function ColorInput:set_rgb(R, G, B)
    local v1, v2, v3 = self.from_rgb(R, G, B)
    v1 = utils.fix_overflow(v1, 0, self.max[1])
    v2 = utils.fix_overflow(v2, 0, self.max[2])
    v2 = utils.fix_overflow(v2, 0, self.max[3])
    self:set(v1, v2, v3)
end

---@return integer v1
---@return integer v2
---@return integer v3
function ColorInput:get()
    return self.v1, self.v2, self.v3
end

---@return integer R
---@return integer G
---@return integer B
function ColorInput:get_rgb()
    return self.to_rgb(self:get())
end

return ColorInput
