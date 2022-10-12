local convert = require("ccc.utils.convert")

---@class HexShortOutput: ColorOutput
local HexShortOutput = {
    name = "HEXshort",
}

---@param RGB RGB
---@param A? Alpha
---@return string
function HexShortOutput.str(RGB, A)
    local R, G, B = convert.rgb_format(RGB)
    R = R / 16
    G = G / 16
    B = B / 16
    if A then
        A = A * 255 / 16
        local pattern = "#%x%x%x%x"
        return pattern:format(R, G, B, A)
    else
        local pattern = "#%x%x%x"
        return pattern:format(R, G, B)
    end
end

return HexShortOutput
