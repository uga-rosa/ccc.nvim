---@class ColorOutput
---@field name string
---@field str fun(RGB: number[], A?: number): string

---@class ColorPicker
---@field parse_color fun(self, s: string, init?: integer, bufnr?: integer): start: integer?, end_: integer?, RGB?, Alpha?, highlightDefinition?

---See `:h nvim_set_hl()`
---@class highlightDefinition
---@field fg string Color name or "#RRDDGG"
---@field bg string Color name or "#RRDDGG"
---@field bold boolean
---@field italic boolean
---@field underline boolean
---@field reverse boolean
---@field strikethrough boolean
