---@class ColorInput
---@field name string
---@field value integer[]
---@field max integer[]
---@field bar_name string[]
---@field from_rgb fun(RGB: integer[]): value: integer[]
---@field to_rgb fun(value: integer[]): RGB: integer[]
local ColorInput = {}

function ColorInput:new()
    return setmetatable({}, { __index = self })
end

---@param value integer[]
function ColorInput:set(value)
    self.value = value
end

---@param RGB integer[]
function ColorInput:set_rgb(RGB)
    self:set(self.from_rgb(RGB))
end

---@return integer[] value
function ColorInput:get()
    return self.value
end

---@return integer[] RGB
function ColorInput:get_rgb()
    return self.to_rgb(self:get())
end

return ColorInput
