---@class HexOutput: ColorOutput
local HexOutput = {
    name = "HEX",
    pattern = "#%02x%02x%02x",
}

---@param RGB integer[]
---@return string
function HexOutput.str(RGB)
    return HexOutput.pattern:format(unpack(RGB))
end

return HexOutput
