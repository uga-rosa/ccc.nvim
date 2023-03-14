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

---@param msg string
---@param ... unknown
function utils.notify(msg, ...)
  if select("#", ...) > 0 then
    msg = msg:format(...)
  end
  vim.notify(msg)
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
function utils.cursor_set(pos)
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
  api.nvim_buf_set_option(bufnr, "modifiable", true)
  api.nvim_buf_set_lines(bufnr, start, end_, false, lines)
  api.nvim_buf_set_option(bufnr, "modifiable", false)
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

---@param array any[]
---@param value any
---@param func? function
---@return integer?
function utils.search_idx(array, value, func)
  func = vim.F.if_nil(func, function(x)
    return x
  end)

  for i, v in ipairs(array) do
    if func(v) == value then
      return i
    end
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

---@param HEX string
---@return boolean
local function is_bright(HEX)
  -- 0-255
  local R = tonumber(HEX:sub(2, 3), 16)
  local G = tonumber(HEX:sub(4, 5), 16)
  local B = tonumber(HEX:sub(6, 7), 16)
  local luminance = 0.298912 * R + 0.586611 * G + 0.114478 * B
  return luminance > 127
end

---@param hex string
---@param hl_mode hl_mode
---@return table
function utils.create_highlight(hex, hl_mode)
  local contrast = is_bright(hex) and "#000000" or "#ffffff"
  if hl_mode == "fg" or hl_mode == "foreground" then
    return { fg = hex, bg = contrast }
  else
    return { fg = contrast, bg = hex }
  end
end

---@param bufnr? integer
---@return integer
function utils.resolve_bufnr(bufnr)
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

---@param tbl table
---@param ... unknown
---@return any
function utils.resolve_tree(tbl, ...)
  for i = 1, select("#", ...) do
    local key = select(i, ...)
    tbl = tbl[key]
    if tbl == nil then
      return
    end
  end
  return tbl
end

return utils
