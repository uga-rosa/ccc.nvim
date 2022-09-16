---@class CssRgbOutput: ColorOutput
local CssRgbOutput = {
    name = "CssRGB",
    pattern = "rgb(%d,%d,%d)",
}

---@param RGB integer[]
---@return string
function CssRgbOutput.str(RGB)
    ---@type string
    return CssRgbOutput.pattern:format(unpack(RGB))
end

return CssRgbOutput
