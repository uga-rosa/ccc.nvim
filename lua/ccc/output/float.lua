local utils = require("ccc.utils")

---@class ccc.ColorOutput
local FloatOutput = {
  name = "Float",
}

function FloatOutput.str(RGB, A)
  local R, G, B = unpack(RGB)
  R = utils.round(R, 3)
  G = utils.round(G, 3)
  B = utils.round(B, 3)
  if A then
    A = utils.round(A, 3)
    return ("(%#.3f,%#.3f,%#.3f,%#.3f)"):format(R, G, B, A)
  else
    return ("(%#.3f,%#.3f,%#.3f)"):format(R, G, B)
  end
end

return FloatOutput
