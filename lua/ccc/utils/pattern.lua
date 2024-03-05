local pattern = {}

---@param str string
---@return string regexp #Very no magic.
function pattern.create(str)
  str = str:gsub("  ", [[\s\+]])
  str = str:gsub(" ", [[\s\*]])
  str = str:gsub("%%%[", [[\%%(]])
  str = str:gsub("%[", [[\(]])
  str = str:gsub("|", [[\|]])
  str = str:gsub("%]", [[\)]])
  str = str:gsub("%?", [[\?]])
  str = str:gsub("<alpha%-value>", [[<number>%%\?]])
  str = str:gsub("<per%-num>", [[<number>%%\?]])
  str = str:gsub("<percentage>", [[<number>%%]])
  str = str:gsub("<hue>", [[<number>\%%(deg\|grad\|rad\|turn\)\?]])
  str = str:gsub("<number>", [=[\[+-]\?\%%(\d\+.\?\d\*\|.\d\+\)]=])
  return "\\V" .. str
end

---@param str string
---@return string?
local function empty2nil(str)
  if str == "" then
    return nil
  end
  return str
end

---@param str string
---@param pat string
---@param init number
---@return integer? start
---@return integer? end
---@return string? ... submatches
function pattern.find(str, pat, init)
  -- matchlist() considers a string containing `\0` as a blob and cannot process them.
  if str:find("\0") then
    return
  end

  local result = vim.fn.matchlist(str:sub(init), pat)
  if #result == 10 then
    local start, end_ = str:find(result[1], init, true)
    table.remove(result, 1)
    result = vim.tbl_map(empty2nil, result)
    return start, end_, unpack(result)
  end
end

return pattern
