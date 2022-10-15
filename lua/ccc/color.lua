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

---@param input_mode? string
---@param output_mode? string
---@param alpha AlphaSlider
---@return CccColor
function Color.new(input_mode, output_mode, alpha)
    local self = setmetatable({
        _inputs = config.get("inputs"),
        _outputs = config.get("outputs"),
        alpha = alpha,
    }, { __index = Color })
    for i, input in ipairs(self._inputs) do
        self._inputs[i] = input:new()
    end

    if input_mode == nil or not self:set_input(input_mode) then
        self.input_idx = 1
        self.input = self._inputs[1]
    end
    if output_mode == nil or not self:set_output(output_mode) then
        self.output_idx = 1
        self.output = self._outputs[1]
    end

    return self
end

local function get_name(x)
    return x.name
end

---@param input_mode string
---@return boolean is_valid_name
function Color:set_input(input_mode)
    local index = utils.search_idx(self._inputs, input_mode, get_name)
    if index then
        self.input_idx = index
        self.input = self._inputs[self.input_idx]
    end
    return index ~= nil
end

---@param output_mode string
---@return boolean is_valid_name
function Color:set_output(output_mode)
    local index = utils.search_idx(self._outputs, output_mode, get_name)
    if index then
        self.output_idx = index
        self.output = self._outputs[self.output_idx]
    end
    return index ~= nil
end

---@return CccColor
function Color:copy()
    local new = Color.new(nil, nil, self.alpha)
    new.input_idx = self.input_idx
    new.input = new._inputs[new.input_idx]
    new:set(self:get())
    new.output_idx = self.output_idx
    new.output = new._outputs[new.output_idx]
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
