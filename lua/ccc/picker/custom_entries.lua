local parse = require("ccc.utils.parse")
local pattern = require("ccc.utils.pattern")

---@class CustomEntries: ColorPicker
---@field rgb { [string]: integer[] }
---@field min_length integer
---@field color_table { [string]: string }
local CustomEntries = {}

---@param color_table { [string]: string }
---@return CustomEntries
CustomEntries.new = function(color_table)
  return setmetatable({ color_table = color_table, rgb = {}, min_length = 0 }, { __index = CustomEntries })
end

function CustomEntries:init()
  if self.pattern then
    return
  end
  ---@type { plain: string, vim: string }[]
  local patterns = {}
  for name, rgb in pairs(self.color_table) do
    local r, g, b = rgb:match("(%x%x)(%x%x)(%x%x)")
    if r then
      local escaped = name:gsub([[\]], "%0%0")
      table.insert(patterns, { plain = name, vim = escaped })
      self.rgb[name] = { parse.hex(r), parse.hex(g), parse.hex(b) }
    end
  end
  -- Sort names to match the longest “word” at first.
  -- If more than one branch matches, the first one is used.
  -- Since keys are not guaranteed to be in 'iskeyword',
  -- we should order them from the longest to the shortest.
  table.sort(patterns, function(a, b)
    return #a.plain > #b.plain
  end)
  self.min_length = #patterns[#patterns].plain
  local vim_patterns = vim.tbl_map(function(v)
    return v.vim
  end, patterns)
  self.pattern = [[\V\<\%(]] .. table.concat(vim_patterns, [[\|]]) .. [[\)\>]]
end

---@param s string
---@param init? integer
---@return integer? start
---@return integer? end_
---@return RGB?
---@return Alpha?
function CustomEntries:parse_color(s, init)
  if vim.tbl_isempty(self.color_table) then
    vim.notify_once("[ccc] no entries for the custom_entries picker", vim.log.levels.WARN)
    return
  end
  self:init()
  init = vim.F.if_nil(init, 1) --[[@as integer]]
  if #s - init + 1 < self.min_length then
    return
  end
  local start, end_ = pattern.find(s, self.pattern, init)
  if start and end_ then
    local name = s:sub(start, end_)
    local rgb = self.rgb[name]
    if rgb then
      return start, end_, rgb
    end
  end
end

return CustomEntries.new
