local sa = require("ccc.utils.safe_array")

---@class HexOutput: ColorOutput
local HexShortOutput = {
    name = "HEXshort",
}

---@param RGB number[]
---@return string
function HexShortOutput.str(RGB)
    local hex = sa.new(RGB)
        :map(function(x)
            return ("%x"):format(x):sub(1, 1)
        end)
        :concat()
    return "#" .. hex
end

return HexShortOutput
