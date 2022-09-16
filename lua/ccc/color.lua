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
---@field _pickers ColorPicker[]
local Color = {}

---@param input_mode? string
---@param output_mode? string
---@return Color
function Color.new(input_mode, output_mode)
    local self = setmetatable({
        _inputs = config.get("inputs"),
        _outputs = config.get("outputs"),
        _pickers = config.get("pickers"),
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
    local new = Color.new()
    new.input_idx = self.input_idx
    new.input = new._inputs[new.input_idx]
    new:set(self:get())
    new.output_idx = self.output_idx
    new.output = new._outputs[new.output_idx]
    return new
end

---@param value integer[]
function Color:set(value)
    self.input:set(value)
end

---@return integer[] value
function Color:get()
    return self.input:get()
end

---@param RGB integer[]
function Color:set_rgb(RGB)
    self.input:set_rgb(RGB)
end

---@return integer[] RGB
function Color:get_rgb()
    return self.input:get_rgb()
end

---@param s string
---@return integer start
---@return integer end_
---@return integer[] RGB
---@overload fun(self: Color, s: string): nil
function Color:pick(s)
    for _, picker in ipairs(self._pickers) do
        local start, end_, RGB = picker:parse_color(s)
        if start then
            return start, end_, RGB
        end
    end
    ---@diagnostic disable-next-line
    return nil
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
    return self.output.str(self.input:get_rgb())
end

---@param value? integer[]
---@return string
function Color:hex(value)
    if not value then
        value = self.input:get()
    end
    local RGB = self.input.to_rgb(value)
    return hex.str(RGB)
end

return Color
