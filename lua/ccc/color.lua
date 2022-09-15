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

---@param input_mode string
---@param output_mode string
---@return Color
function Color.new(input_mode, output_mode)
    local self = setmetatable({
        _inputs = config.get("inputs"),
        _outputs = config.get("outputs"),
        _pickers = config.get("pickers"),
    }, { __index = Color })

    self:set_input(input_mode)
    self:set_output(output_mode)

    return self
end

local function get_name(x)
    return x.name
end

function Color:set_input(input_mode)
    self.input_idx = assert(
        utils.search_idx(self._inputs, input_mode, get_name),
        "Invalid input mode: " .. input_mode
    )
    self.input = self._inputs[self.input_idx]
end

function Color:set_output(output_mode)
    self.output_idx = assert(
        utils.search_idx(self._outputs, output_mode, get_name),
        "Invalid output mode: " .. output_mode
    )
    self.output = self._outputs[self.output_idx]
end

---@return Color
function Color:copy()
    local new = setmetatable({}, { __index = Color })
    for k, v in pairs(self) do
        new[k] = v
    end
    return new
end

---@param v1 integer
---@param v2 integer
---@param v3 integer
function Color:set(v1, v2, v3)
    self.input:set(v1, v2, v3)
end

---@return integer v1
---@return integer v2
---@return integer v3
function Color:get()
    return self.input:get()
end

---@param R integer
---@param G integer
---@param B integer
function Color:set_rgb(R, G, B)
    self.input:set_rgb(R, G, B)
end

---@return integer R
---@return integer G
---@return integer G
function Color:get_rgb()
    return self.input:get_rgb()
end

---@param s string
---@return integer start
---@return integer end_
---@return integer R
---@return integer G
---@return integer B
---@overload fun(self: Color, s: string): nil
function Color:pick(s)
    for _, picker in ipairs(self._pickers) do
        local start, end_, R, G, B = picker:parse_color(s)
        if start then
            return start, end_, R, G, B
        end
    end
    ---@diagnostic disable-next-line
    return nil
end

function Color:toggle_input()
    local R, G, B = self.input:get_rgb()
    if self.input_idx == #self._inputs then
        self.input_idx = 1
    else
        self.input_idx = self.input_idx + 1
    end
    self.input = self._inputs[self.input_idx]
    self.input:set_rgb(R, G, B)
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

---@param v1? integer
---@param v2? integer
---@param v3? integer
---@return string
function Color:hex(v1, v2, v3)
    if not (v1 and v2 and v3) then
        v1, v2, v3 = self.input:get()
    end
    local R, G, B = self.input.to_rgb(v1, v2, v3)
    return hex.str(R, G, B)
end

return Color
