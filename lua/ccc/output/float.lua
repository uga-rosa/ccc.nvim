local convert = require("ccc.utils.convert")

---@class FloatOutput: ColorOutput
local FloatOutput = {
    name = "Float",
}

---@param RGB number[]
---@param A? number
---@return string
function FloatOutput.str(RGB, A)
    local R, G, B = convert.rgb_format(RGB)
    R = R / 256
    G = G / 256
    B = B / 256
    if A then
        local pattern = "(%#.3f,%#.3f,%#.3f,%#.3f)"
        return pattern:format(R, G, B, A)
    else
        local pattern = "(%#.3f,%#.3f,%#.3f)"
        return pattern:format(R, G, B)
    end
end

return FloatOutput
