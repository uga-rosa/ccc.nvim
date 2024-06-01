local HexPicker = require("ccc.picker.hex")

---@class ccc.ColorPicker.HexShort: ccc.ColorPicker.Hex
local HexShortPicker = setmetatable({}, { __index = HexPicker })

-- #RGB
-- #RGBA
HexShortPicker.pattern = {
  [=[\v%(^|[^[:keyword:]])\zs#(\x)(\x)(\x)>]=],
  [=[\v%(^|[^[:keyword:]])\zs#(\x)(\x)(\x)(\x)>]=],
}

return HexShortPicker
