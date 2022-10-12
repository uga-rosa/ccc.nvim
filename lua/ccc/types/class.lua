---@class ColorOutput
---@field name string
---@field str fun(RGB: number[], A?: number): string

---@class ColorPicker
---@field pattern string[] | string
---@field exclude_pattern string[]
---@field init fun(self)
---@field parse_color fun(self: ColorPicker, s: string, init?: integer): start: integer?, end_: integer?, RGB: number[]?, alpha: number?
