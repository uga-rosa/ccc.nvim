---@class ColorOutput
---@field name string
---@field str fun(RGB: number[], A?: number): string

---@class ColorPicker
---@field parse_color fun(self, s: string, init?: integer, bufnr?: integer): start: integer?, end_: integer?, RGB?, Alpha?, vim.api.keyset.highlight?
