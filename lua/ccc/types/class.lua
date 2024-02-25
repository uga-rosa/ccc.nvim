---@class ccc.UI
---@field bufnr integer
---@field winid integer
---@field ns_id integer
---@field color ccc.Color
---@field show_prev_colors boolean
---@field before_color ccc.Color
---@field prev_colors ccc.PrevColors
---@field is_quit boolean
---@field on_quit_callback? function
---@field new fun(): ccc.UI
---@field open fun(self: ccc.UI, color: ccc.Color, prev_colors: ccc.PrevColors)
---@field update fun(self: ccc.UI)
---@field close fun(self: ccc.UI)
---@field on_close fun(self: ccc.UI)
---@field reset_view fun(self: ccc.UI)
---@field point_at fun(self: ccc.UI): ccc.UI.point
---@field set_point fun(self: ccc.UI, point: ccc.UI.point)

---@class ccc.UI.point
---@field type "none" | "color" | "alpha" | "prev"
---@field index integer

---@class ccc.ColorInput
---@field name string
---@field value number[]
---@field max number[]
---@field min number[]
---@field delta number[] #Minimum slider movement.
---@field bar_name string[] #Align all display widths.
---@field format fun(n: number, i: integer): string #String returned must be 6 byte.
---@field from_rgb fun(RGB: RGB): value: number[]
---@field to_rgb fun(value: number[]): RGB
---@field callback fun(self: ccc.ColorInput, new_value: number, index: integer)

---@class ccc.ColorOutput
---@field name string
---@field str fun(RGB: number[], A?: number): string

---@class ccc.ColorPicker
---@field parse_color fun(self, s: string, init?: integer, bufnr?: integer): start: integer?, end_: integer?, RGB: RGB?, Alpha: Alpha?, hl_def: vim.api.keyset.highlight?

---@alias ccc.Position integer[] { row, col } 0-indexed
---@alias ccc.Range integer[] { start_row, start_col, end_row, end_col } 0-indexed, Only end_col is exclusive

---@class ccc.hl_info
---@field range ccc.Range
---@field hl_name string
