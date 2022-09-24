local utils = require("ccc.utils")
local config = require("ccc.config")
local hex = require("ccc.output.hex")

---@class Color
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
---@return Color
function Color.new(input_mode, output_mode, alpha)
    local self = setmetatable({
        _inputs = config.get("inputs"),
        _outputs = config.get("outputs"),
        alpha = alpha,
    }, { __index = Color })
    for i, input in ipairs(self._inputs) do
        self._inputs[i] = input:new()
    end

    if input_mode and output_mode then
        self:set_input(input_mode)
        self:set_output(output_mode)
    else
        self.input_idx = 1
        self.output_idx = 1
        self.input = self._inputs[1]
        self.output = self._outputs[1]
    end

    return self
end

local function get_name(x)
    return x.name
end

---@param input_mode string
function Color:set_input(input_mode)
    self.input_idx = assert(
        utils.search_idx(self._inputs, input_mode, get_name),
        "Invalid input mode: " .. input_mode
    )
    self.input = self._inputs[self.input_idx]
end

---@param output_mode string
function Color:set_output(output_mode)
    self.output_idx = assert(
        utils.search_idx(self._outputs, output_mode, get_name),
        "Invalid output mode: " .. output_mode
    )
    self.output = self._outputs[self.output_idx]
end

---@return Color
function Color:copy()
    local new = Color.new(nil, nil, self.alpha)
    new.input_idx = self.input_idx
    new.input = new._inputs[new.input_idx]
    new:set_rgb(self:get_rgb())
    new.output_idx = self.output_idx
    new.output = new._outputs[new.output_idx]
    return new
end

---@param value number[]
function Color:set(value)
    self.input:set(value)
end

---@return number[] value
function Color:get()
    return self.input:get()
end

---@param RGB number[]
function Color:set_rgb(RGB)
    self.input:set_rgb(RGB)
end

---@return number[] RGB
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
    return self.output.str(self.input:get_rgb(), self.alpha)
end

---@param index? integer
---@param new_value? number
---@return string
function Color:hex(index, new_value)
    local RGB
    if index and new_value then
        local pre = self:get_rgb()
        self.input:callback(index, new_value)
        RGB = self.input:get_rgb()
        self:set_rgb(pre)
    else
        RGB = self.input:get_rgb()
    end
    return hex.str(RGB)
end

return Color
