local utils = require("ccc.utils")
local hex = require("ccc.utils.hex")

local M = {
  hl_name_cache = {},
}

function M.reset()
  M.hl_name_cache = {}
end

---@param rgb? RGB
---@param hl_def? vim.api.keyset.highlight
---@return string hl_name
function M.ensure_hl_name(rgb, hl_def)
  local hl_name = "CccHighlighter"
  if hl_def then
    hl_name = hl_name
      .. (hl_def.fg and "fg" .. hl_def.fg:sub(2) or "")
      .. (hl_def.bg and "bg" .. hl_def.bg:sub(2) or "")
      .. (hl_def.bold and "bold" or "")
      .. (hl_def.italic and "italic" or "")
      .. (hl_def.underline and "underline" or "")
      .. (hl_def.reverse and "reverse" or "")
      .. (hl_def.strikethrough and "strikethrough" or "")
  elseif rgb then
    local color = hex.stringify(rgb)
    hl_name = hl_name .. color:sub(2)
    local opts = require("ccc.config").options
    hl_def = utils.create_highlight(color, opts.highlight_mode)
  else
    return ""
  end

  if not M.hl_name_cache[hl_name] then
    vim.api.nvim_set_hl(0, hl_name, hl_def)
    M.hl_name_cache[hl_name] = true
  end
  return hl_name
end

return M
