---@alias lsp.ColorInformation { range: lsp.Range, color: lsp.Color }

---@alias lsp.Color { red: number, green: number, blue: number, alpha: number }
---All values range from 0 to 1.

---@alias lsp.Range { start: lsp.Position, end: lsp.Position }

---@alias lsp.Position { line: integer, character: integer }
---The line field means row number (zero-based).
---The character field means col number (zero-based).
