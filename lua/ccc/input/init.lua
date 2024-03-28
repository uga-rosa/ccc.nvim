local utils = require("ccc.utils")

---@class ccc.ColorInput
local ColorInput = {}

---@param n number
---@return string
function ColorInput.format(n, _)
  n = utils.round(n)
  return ("%6d"):format(n)
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
  for i, v in ipairs(value) do
    value[i] = utils.clamp(v, self.min[i], self.max[i])
  end
  self.value = value
end

---@param RGB RGB
function ColorInput:set_rgb(RGB)
  self:set(self.from_rgb(RGB))
end

--- Returns a shallow copy
---@return number[] value
function ColorInput:get()
  return { unpack(self.value) }
end

---@return RGB
function ColorInput:get_rgb()
  return self.to_rgb(self:get())
end

return ColorInput
