---@class ColorInput
---@field name string
---@field value number[]
---@field max number[]
---@field min number[]
---@field delta number[] #Minimum slider movement.
---@field bar_name string[] #Align all display widths.
---@field format fun(v: number): string #String returned must be 6 byte.
---@field from_rgb fun(RGB: integer[]): value: number[]
---@field to_rgb fun(value: number[]): RGB: integer[]
---@field callback fun(self: ColorInput, new_value: number, index: integer): value: integer[]
local ColorInput = {}

function ColorInput.format(v)
    return ("%6d"):format(v)
end

function ColorInput:new()
    return setmetatable({}, { __index = self })
end

---@param index integer
---@param new_value number
function ColorInput:callback(index, new_value)
    self.value[index] = new_value
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
