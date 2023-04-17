---@class lsp.ColorInformation
---@field color lsp.Color
---@field range lsp.Range

---All values range from 0 to 1.
---@class lsp.Color
---@field red number
---@field green number
---@field blue number
---@field alpha number

---@class lsp.Range
---@field start lsp.Position
---@field end lsp.Position

---The line field means row number (zero-based).
---The character field means col number (zero-based).
---@class lsp.Position
---@field line integer
---@field character integer
