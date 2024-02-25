local array = require("ccc.utils.array")
local utils = require("ccc.utils")

---@class ccc.PrevColors
---@field _values estrela.array ccc.Color[]
---@field _index integer
local PrevColors = {}
PrevColors.__index = PrevColors

---@return ccc.PrevColors
function PrevColors.new()
  return setmetatable({
    _values = array.new(),
    _index = 1,
  }, PrevColors)
end

function PrevColors:reset()
  self._values = array.new()
  self._index = 1
end

---@param color ccc.Color
function PrevColors:prepend(color)
  local opts = require("ccc.config").options
  if opts.max_prev_colors < self._values:unshift(color) then
    self._values = self._values:slice(1, opts.max_prev_colors)
  end
end

---@return ccc.Color
function PrevColors:get()
  return self._values[self._index]
end

---@return ccc.Color[]
function PrevColors:get_all()
  return self._values
end

---@return integer
function PrevColors:get_index()
  return self._index
end

---@return string
function PrevColors:str()
  return self._values:map("x:hex()"):join(" ")
end

---@param d integer
function PrevColors:delta(d)
  self._index = utils.clamp(self._index + d, 1, #self._values)
end

return PrevColors
