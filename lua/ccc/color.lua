local utils = require("ccc.utils")
local config = require("ccc.config")
local hex = require("ccc.output.hex")

---@class CccColor
---@field input ColorInput
---@field input_idx integer
---@field output ColorOutput
---@field output_idx integer
---@field _inputs ColorInput[]
---@field _outputs ColorOutput[]
---@field alpha AlphaSlider
local Color = {}

---@param input_name? string
---@param output_name? string
---@param alpha AlphaSlider
---@return CccColor
function Color.new(input_name, output_name, alpha)
  local self = setmetatable({
    _inputs = config.get("inputs"),
    _outputs = config.get("outputs"),
    alpha = alpha,
  }, { __index = Color })
  for i, input in ipairs(self._inputs) do
    self._inputs[i] = input:new()
  end

  if input_name then
    self:set_input(input_name)
  end
  if output_name then
    self:set_output(output_name)
  end

  return self
end

local function get_name(x)
  return x.name
end

---@param input_name string
function Color:set_input(input_name)
  local index = utils.search_idx(self._inputs, input_name, get_name)
  if index then
    self.input_idx = index
    self.input = self._inputs[self.input_idx]
  else
    self.input_idx = 1
    self.input = self._inputs[1]
  end
end

---@param output_name string
function Color:set_output(output_name)
  local index = utils.search_idx(self._outputs, output_name, get_name)
  if index then
    self.output_idx = index
    self.output = self._outputs[self.output_idx]
  else
    self.output_idx = 1
    self.output = self._outputs[1]
  end
end

---@return CccColor
function Color:copy()
  local new = Color.new(self.input.name, self.output.name, self.alpha)
  new:set(self:get())
  return new
end

---@param value number[]
function Color:set(value)
  self.input:set(value)
end

---Return a copy
---@return number[] value
function Color:get()
  return { unpack(self.input:get()) }
end

---@param RGB RGB
function Color:set_rgb(RGB)
  self.input:set_rgb(RGB)
end

---@return RGB
function Color:get_rgb()
  return self.input:get_rgb()
end

function Color:toggle_input()
  local RGB = self.input:get_rgb()
  if self.input_idx == #self._inputs then
    self.input_idx = 1
  else
    self.input_idx = self.input_idx + 1
  end
  self.input = self._inputs[self.input_idx]
  self.input:set_rgb(RGB)
end

function Color:toggle_output()
  if self.output_idx == #self._outputs then
    self.output_idx = 1
  else
    self.output_idx = self.output_idx + 1
  end
  self.output = self._outputs[self.output_idx]
end

---@return string
function Color:str()
  local A
  if self.alpha.is_showed then
    A = self.alpha:get()
  end
  return self.output.str(self.input:get_rgb(), A)
end

---@param index? integer
---@param new_value? number
---@return string
function Color:hex(index, new_value)
  local RGB
  if index and new_value then
    local pre = self:get()
    self.input:callback(index, new_value)
    RGB = self:get_rgb()
    self:set(pre)
  else
    RGB = self.input:get_rgb()
  end
  return hex.str(RGB)
end

return Color
