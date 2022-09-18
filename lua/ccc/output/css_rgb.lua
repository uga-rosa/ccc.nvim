local convert = require("ccc.utils.convert")

---@class CssRgbOutput: ColorOutput
local CssRgbOutput = {
    name = "CssRGB",
}

---@param RGB number[]
---@param alpha AlphaSlider
---@return string
function CssRgbOutput.str(RGB, alpha)
    local R, G, B = convert.rgb_format(RGB)
    if alpha.is_showed then
        local pattern = "rgb(%d,%d,%d,%d%%)"
        local A = alpha:get() * 100
        return pattern:format(R, G, B, A)
    else
        local pattern =  "rgb(%d,%d,%d)"
        return pattern:format(R, G, B)
    end
end

return CssRgbOutput
