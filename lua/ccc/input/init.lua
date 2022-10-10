---@class ColorInput
---@field name string
---@field value number[]
---@field max number[]
---@field min number[]
---@field delta number[] #Minimum slider movement.
---@field bar_name string[] #Align all display widths.
---@field format fun(n: number, i: integer): string #String returned must be 6 byte.
---@field from_rgb fun(RGB: RGB): value: number[]
---@field to_rgb fun(value: number[]): RGB
---@field callback fun(self: ColorInput, new_value: number, index: integer): value: integer[]
local ColorInput = {}

---@param n number
---@return string
function ColorInput.format(n, _)
    return ("%6d"):format(n):sub(1, 6)
end

function ColorInput:new()
    return setmetatable({}, { __index = self })
end

---@param index integer
---@param new_value number
function ColorInput:callback(index, new_value)
    self.value[index] = new_value
end

---@param value number[]
function ColorInput:set(value)
    self.value = value
end

---@param RGB RGB
function ColorInput:set_rgb(RGB)
    self:set(self.from_rgb(RGB))
end

---@return number[] value
function ColorInput:get()
    return self.value
end

---@return RGB
function ColorInput:get_rgb()
    return self.to_rgb(self:get())
end

return ColorInput
