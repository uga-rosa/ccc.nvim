local hex = require("ccc.utils.hex")

---@class ccc.ColorAlpha
---@field value number 0-1
---@field is_hide boolean
local ColorAlpha = {}
ColorAlpha.__index = ColorAlpha

function ColorAlpha.new()
  local opts = require("ccc.config").options
  return setmetatable({
    value = 1,
    is_hide = opts.alpha_show ~= "show",
  }, ColorAlpha)
end

function ColorAlpha:show()
  self.is_hide = false
end

function ColorAlpha:hide()
  self.is_hide = true
end

function ColorAlpha:toggle()
  self.is_hide = not self.is_hide
end

function ColorAlpha:reset()
  self.value = 1
  local opts = require("ccc.config").options
  self.is_hide = opts.alpha_show ~= "show"
end

---@param value number
function ColorAlpha:set(value)
  self.value = value
  local opts = require("ccc.config").options
  if opts.alpha_show == "auto" then
    self.is_hide = false
  end
end

---@return number?
function ColorAlpha:get()
  if self.is_hide then
    return
  end
  return self.value
end

---For slider
---@return string
function ColorAlpha:str()
  return ("%5d%%"):format(self.value * 100)
end

---@param value? number
function ColorAlpha:hex(value)
  value = value or self.value
  return hex.stringify({ value, value, value })
end

return ColorAlpha
