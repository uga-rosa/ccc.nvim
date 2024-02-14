local api = vim.api

local utils = {}

---@param key string
---@param plain? boolean
function utils.feedkey(key, plain)
  if not plain then
    key = api.nvim_replace_termcodes(key, true, false, true)
  end
  api.nvim_feedkeys(key, "n", false)
end

---(1,1)-index
---@return integer[]
function utils.cursor()
  local pos = api.nvim_win_get_cursor(0)
  pos[2] = pos[2] + 1
  return pos
end

---(1,1)-index
---@param pos integer[]
function utils.set_cursor(pos)
  pos[2] = pos[2] - 1
  pcall(api.nvim_win_set_cursor, 0, pos)
end

---1-index
---@return integer
function utils.row()
  return utils.cursor()[1]
end

---1-index
---@return integer
function utils.col()
  return utils.cursor()[2]
end

---@param bufnr integer
---@param start integer
---@param end_ integer
---@param lines string[]
function utils.set_lines(bufnr, start, end_, lines)
  api.nvim_set_option_value("modifiable", true, { buf = bufnr })
  api.nvim_buf_set_lines(bufnr, start, end_, false, lines)
  api.nvim_set_option_value("modifiable", false, { buf = bufnr })
end

---@param bufnr integer
---@param lnum integer 1-index
---@return integer
function utils.line_length(bufnr, lnum)
  local line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
  return vim.api.nvim_strwidth(line)
end

---@param bufnr integer
---@param ns_id integer
---@param range lsp.Range
---@param name string
---@param hl_def? vim.api.keyset.highlight
function utils.set_hl(bufnr, ns_id, range, name, hl_def)
  if hl_def then
    vim.api.nvim_set_hl(ns_id, name, hl_def)
  end
  vim.api.nvim_buf_add_highlight(bufnr, ns_id, name, range.start.line, range.start.character, range["end"].character)
end

---@param sl integer start line
---@param sc integer start character
---@param el integer end line
---@param ec integer end character
---@return lsp.Range
function utils.range(sl, sc, el, ec)
  return { start = { line = sl, character = sc }, ["end"] = { line = el, character = ec } }
end

---@param ... number
---@return number max
function utils.max(...)
  local max = select(1, ...)
  for i = 2, select("#", ...) do
    local x = select(i, ...)
    if max < x then
      max = x
    end
  end
  return max
end

---@param ... number
---@return number min
function utils.min(...)
  local min = select(1, ...)
  for i = 2, select("#", ...) do
    local x = select(i, ...)
    if min > x then
      min = x
    end
  end
  return min
end

---@param float number
---@param digit? integer
---@return integer
function utils.round(float, digit)
  if digit then
    return math.floor(float * 10 ^ digit + 0.5) / 10 ^ digit
  else
    return math.floor(float + 0.5)
  end
end

---@param int integer
---@param min integer
---@param max integer
---@return integer
function utils.clamp(int, min, max)
  if int < min then
    return min
  elseif int > max then
    return max
  end
  return int
end

---@param R integer #0-255
---@param G integer #0-255
---@param B integer #0-255
---@return boolean
function utils.is_bright_RGB(R, G, B)
  local luminance = 0.298912 * R + 0.586611 * G + 0.114478 * B
  return luminance > 127
end

---@param HEX string
---@return boolean
local function is_bright_HEX(HEX)
  -- 0-255
  local R = tonumber(HEX:sub(2, 3), 16)
  local G = tonumber(HEX:sub(4, 5), 16)
  local B = tonumber(HEX:sub(6, 7), 16)
  return utils.is_bright_RGB(R, G, B)
end

---@param hex string
---@param hl_mode ccc.Option.hl_mode
---@return vim.api.keyset.highlight
function utils.create_highlight(hex, hl_mode)
  local contrast = is_bright_HEX(hex) and "#000000" or "#ffffff"
  if hl_mode == "fg" or hl_mode == "foreground" then
    return { fg = hex, bg = contrast }
  else
    return { fg = contrast, bg = hex }
  end
end

---@param bufnr? integer
---@return integer
function utils.ensure_bufnr(bufnr)
  if bufnr == nil or bufnr == 0 then
    return api.nvim_get_current_buf()
  end
  return bufnr
end

---@param value? number|number[]
---@param min number
---@param max number
---@return boolean
function utils.valid_range(value, min, max)
  if type(value) == "number" then
    return min <= value and value <= max
  elseif type(value) == "table" then
    for _, v in ipairs(value) do
      if v < min or max < v then
        return false
      end
    end
    return true
  end
  return false
end

function utils.bind(func, ...)
  local args = { ... }
  return function(...)
    for _, v in ipairs({ ... }) do
      table.insert(args, v)
    end
    func(unpack(args))
  end
end

---optional chain
---@param root table
---@param ... unknown keys
---@return unknown | nil
function utils.oc(root, ...)
  for _, key in ipairs({ ... }) do
    root = root[key]
    if root == nil then
      return
    end
  end
  return root
end

return utils
