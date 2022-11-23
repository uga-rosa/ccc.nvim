---@class FloatOutput: ColorOutput
local FloatOutput = {
  name = "Float",
}

---@param RGB RGB
---@param A? Alpha
---@return string
function FloatOutput.str(RGB, A)
  local R, G, B = unpack(RGB)
  if A then
    return ("(%#.3f,%#.3f,%#.3f,%#.3f)"):format(R, G, B, A)
  else
    return ("(%#.3f,%#.3f,%#.3f)"):format(R, G, B)
  end
end

return FloatOutput
