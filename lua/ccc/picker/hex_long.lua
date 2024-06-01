local HexPicker = require("ccc.picker.hex")

---@class ccc.ColorPicker.HexLong: ccc.ColorPicker.Hex
local HexLongPicker = setmetatable({}, { __index = HexPicker })

-- #RRGGBB
-- #RRGGBBAA
HexLongPicker.pattern = {
  [=[\v%(^|[^[:keyword:]])\zs#(\x\x)(\x\x)(\x\x)>]=],
  [=[\v%(^|[^[:keyword:]])\zs#(\x\x)(\x\x)(\x\x)(\x\x)>]=],
}

return HexLongPicker
