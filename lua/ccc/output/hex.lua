local convert = require("ccc.utils.convert")

---@class HexOutput: ColorOutput
local HexOutput = {
  name = "HEX",
}

---@param RGB RGB
---@param A? Alpha
---@return string
function HexOutput.str(RGB, A)
  local R, G, B = convert.rgb_format(RGB)
  if A then
    A = A * 255
    local pattern = "#%02x%02x%02x%02x"
    return pattern:format(R, G, B, A)
  else
    local pattern = "#%02x%02x%02x"
    return pattern:format(R, G, B)
  end
end

return HexOutput
