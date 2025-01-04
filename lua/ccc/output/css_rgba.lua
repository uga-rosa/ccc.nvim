local convert = require("ccc.utils.convert")

---@class ccc.ColorOutput
local CssRgbaOutput = {
  name = "CssRGBA",
}

function CssRgbaOutput.str(RGB, A)
  local R, G, B = convert.rgb_format(RGB)
  if A then
    -- to fix 0.00 0. 1.00 1.10 and etc.
    A = string.format("%.2f", A):gsub("0+$", ""):gsub("%.$", "")
    return ("rgba(%d, %d, %d, %s)"):format(R, G, B, A)
  else
    return ("rgba(%d, %d, %d, 1)"):format(R, G, B)
  end
end

return CssRgbaOutput
