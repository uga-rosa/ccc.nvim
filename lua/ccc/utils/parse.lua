local parse = {}

---@param str string
---@param min? number
---@param max? number
---@param base? integer
---@return number?
function parse.number(str, min, max, base)
  base = vim.F.if_nil(base, 10)
  local n = tonumber(str, base)
  if n and (min == nil or min <= n) and (max == nil or n <= max) then
    return n
  end
end

---@param str string
---@return number? deg
function parse.angle(str)
  local x
  if vim.endswith(str, "deg") then
    str = str:sub(1, -4)
    x = tonumber(str)
  elseif vim.endswith(str, "grad") then
    str = str:sub(1, -5)
    x = tonumber(str)
    if x then
      x = x / 400 * 360
    end
  elseif vim.endswith(str, "rad") then
    str = str:sub(1, -4)
    x = tonumber(str)
    if x then
      x = x / (2 * math.pi) * 360
    end
  elseif vim.endswith(str, "turn") then
    str = str:sub(1, -5)
    x = tonumber(str)
    if x then
      x = x * 360
    end
  end
  return x
end

---@param str string
---@return number? deg #Normalized degree in the range [0-360].
function parse.hue(str)
  if str == "none" then
    return 0
  end
  local num = parse.number(str) or parse.angle(str)
  if num then
    return num % 360
  end
end

---@param str? string
---@return number? #Normalized to the range in [0-1] instead of [0-255].
function parse.hex(str)
  if str == nil or #str > 2 then
    return
  elseif #str == 1 then
    str = str .. str
  end
  local num = tonumber(str, 16)
  if num then
    return num / 255
  end
end

---Since the range of value is unknown, use utils.valid_range() later.
---@param str string
---@param ratio? number #Default: 1
---@param percent? boolean #Default: false. If true, return range is corrected to [0-1]
---@return number?
function parse.percent(str, ratio, percent)
  if str == "none" then
    return 0
  end

  ratio = vim.F.if_nil(ratio, 1)
  percent = vim.F.if_nil(percent, false)

  local result
  if str:sub(-1, -1) == "%" then
    str = str:sub(1, -2)
    local num = tonumber(str)
    if num then
      result = num / 100
    end
  else
    ratio = vim.F.if_nil(ratio, 1)
    local num = tonumber(str)
    if num then
      result = num / ratio
    end
  end

  if not percent then
    result = result * ratio
  end

  return result
end

---@param str? string
---@return number? #Range in [0-1]
function parse.alpha(str)
  if str == "none" then
    return 0
  elseif str == nil then
    return
  end
  return parse.percent(str)
end

return parse
