local pattern = require("ccc.utils.pattern")

local definition = {
  ["1"] = { bold = true },
  -- 2, faint/dim can't support
  ["3"] = { italic = true },
  ["4"] = { underline = true },
  -- 5 and 6, slow/papid blink can't support
  ["7"] = { reverse = true },
  -- 8, conceal/hide can't support
  ["9"] = { strikethrough = true },

  -- Foreground colors
  ["30"] = { fg = "black" },
  ["31"] = { fg = "red" },
  ["32"] = { fg = "green" },
  ["33"] = { fg = "yellow" },
  ["34"] = { fg = "blue" },
  ["35"] = { fg = "magenta" },
  ["36"] = { fg = "cyan" },
  ["37"] = { fg = "white" },

  -- Background colors
  ["40"] = { bg = "black" },
  ["41"] = { bg = "red" },
  ["42"] = { bg = "green" },
  ["43"] = { bg = "yellow" },
  ["44"] = { bg = "blue" },
  ["45"] = { bg = "magenta" },
  ["46"] = { bg = "cyan" },
  ["47"] = { bg = "white" },

  -- Bright colors (aixterm specification)
  -- Foreground colors
  ["90"] = { fg = "bright_black" },
  ["91"] = { fg = "bright_red" },
  ["92"] = { fg = "bright_green" },
  ["93"] = { fg = "bright_yellow" },
  ["94"] = { fg = "bright_blue" },
  ["95"] = { fg = "bright_magenta" },
  ["96"] = { fg = "bright_cyan" },
  ["97"] = { fg = "bright_white" },
  -- Background colors
  ["100"] = { bg = "bright_black" },
  ["101"] = { bg = "bright_red" },
  ["102"] = { bg = "bright_green" },
  ["103"] = { bg = "bright_yellow" },
  ["104"] = { bg = "bright_blue" },
  ["105"] = { bg = "bright_magenta" },
  ["106"] = { bg = "bright_cyan" },
  ["107"] = { bg = "bright_white" },
}

-- This color scheme came from Campbell (WindowsTerminal)
local default_name2color = {
  foreground = "#cccccc",
  background = "#0c0c0c",
  black = "#0c0c0c",
  red = "#c50f1f",
  green = "#13a10e",
  yellow = "#c19c00",
  blue = "#0037da",
  magenta = "#881798",
  cyan = "#3a96dd",
  white = "#cccccc",
  bright_black = "#767676",
  bright_red = "#e74856",
  bright_green = "#16c60c",
  bright_yellow = "#f9f1a5",
  bright_blue = "#3b78ff",
  bright_magenta = "#b4009e",
  bright_cyan = "#61d6d6",
  bright_white = "#f2f2f2",
}

---@class ccc.ColorPicker.AnsiEscape: ccc.ColorPicker
---@field pattern string
---@field name2color { [string]: string }
---@field meaning1 "bold"|"bright"
local AnsiEscapePicker = {
  -- ESC[{code}m: {code} is numbers separated by `;`.
  -- Escape expression: \u001b, \033, \x1b, 27, ^[, \e
  -- Appearing in a string, `\` may be escaped to become `\\` (\\\?\\).
  pattern = [=[\V\c\%(\\\?\\u001b\|\\\?\\033\|\\\?\\x1b\|27\|\^[\|\\\?\\e\)[\(\[0-9;]\+\)m]=],
  meaning1 = "bright",
}
AnsiEscapePicker.__index = AnsiEscapePicker

---@param name2color? { [string]: string }
---@param opts? table
---@return ccc.ColorPicker.AnsiEscape
function AnsiEscapePicker.new(name2color, opts)
  name2color = name2color or {}
  opts = opts or {}
  return setmetatable({
    name2color = vim.tbl_extend("keep", name2color, default_name2color),
    meaning1 = opts.meaning1,
  }, AnsiEscapePicker)
end

---@param s string
---@param init? integer
---@return integer? start_col
---@return integer? end_col
---@return nil rgb
---@return nil alpha
---@return vim.api.keyset.highlight? hl_def
function AnsiEscapePicker:parse_color(s, init)
  init = init or 1

  local start_col, end_col, codes = pattern.find(s, self.pattern, init)
  if not (start_col and end_col and codes) then
    return
  end

  local hl_def = {}
  for code in vim.gsplit(codes, ";") do
    hl_def = vim.tbl_extend("force", hl_def, definition[code] or {})
  end

  if self.meaning1 == "bright" and hl_def.bold then
    hl_def.bold = nil
    hl_def.fg = hl_def.fg and "bright_" .. hl_def.fg
    hl_def.bg = hl_def.bg and "bright_" .. hl_def.bg
  end
  hl_def.fg = hl_def.fg and self.name2color[hl_def.fg] or self.name2color["foreground"]
  hl_def.bg = hl_def.bg and self.name2color[hl_def.bg] or self.name2color["background"]

  return start_col, end_col, nil, nil, hl_def
end

return AnsiEscapePicker.new
