local utils = require("ccc.utils")
local convert = require("ccc.utils.convert")

---@class ccc.ColorOutput
local CssRgbOutput = {
  name = "CssRGB",
}

function CssRgbOutput.str(RGB, A)
  local R, G, B = convert.rgb_format(RGB)
  if A then
    A = utils.round(A * 100)
    return ("rgb(%d %d %d / %d%%)"):format(R, G, B, A)
  else
    return ("rgb(%d %d %d)"):format(R, G, B)
  end
end

return CssRgbOutput
