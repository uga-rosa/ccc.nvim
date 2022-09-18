local UI = require("ccc.ui")
local convert = require("ccc.utils.convert")

---@class CssRgbOutput: ColorOutput
local CssRgbOutput = {
    name = "CssRGB",
}

---@param RGB number[]
---@return string
function CssRgbOutput.str(RGB)
    local R, G, B = convert.rgb_format(RGB)
    if UI.alpha.is_showed then
        local pattern = "rgb(%d,%d,%d,%d%%)"
        local A = UI.alpha:get() * 100
        return pattern:format(R, G, B, A)
    else
        local pattern =  "rgb(%d,%d,%d)"
        return pattern:format(R, G, B)
    end
end

return CssRgbOutput
