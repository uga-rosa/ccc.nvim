local config = require("ccc.config")
local utils = require("ccc.utils")
local parse = require("ccc.utils.parse")

---@class CustomEntries: ColorPicker
---@field rgb { [string]: integer[] }
---@field re { match_str: function } vim.regex instance
---@field min_length integer
---@field color_table { [string]: string }
---@field exclude_pattern_option string[]|string
local CustomEntries = {}

---@param color_table { [string]: string }
---@return CustomEntries
CustomEntries.new = function(color_table)
  return setmetatable(
    { color_table = color_table, rgb = {}, pattern = {}, exclude_pattern = {} },
    { __index = CustomEntries }
  )
end

function CustomEntries:init()
  if self.re then
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
  -- Sort names to match the longest word at first.
  table.sort(patterns, function(a, b)
    return #a.plain > #b.plain
  end)
  self.min_length = #patterns[#patterns].plain
  local vim_patterns = vim.tbl_map(function(v)
    return v.vim
  end, patterns)
  local pattern = [[\V\<\%(]] .. table.concat(vim_patterns, [[\|]]) .. [[\)\>]]
  self.exclude_pattern_option = config.get("exclude_pattern").custom_entries
  self.re = vim.regex(pattern) --[[@as { match_str: function }]]
end

---@param s string
---@param init? integer
---@return integer? start
---@return integer? end_
---@return RGB?
---@return Alpha?
function CustomEntries:parse_color(s, init)
  self:init()
  init = vim.F.if_nil(init, 1) --[[@as integer]]
  local target = s:sub(init)
  if #target < self.min_length then
    return
  end
  local target_start, target_end = self.re:match_str(target)
  if target_start then
    local name = target:sub(target_start + 1, target_end)
    local rgb = self.rgb[name]
    if rgb then
      local start = target_start + init
      local end_ = target_end + init - 1
      local escaped = name:gsub("[$^()%%.%[%]*+-?]", "%%%0")
      local exclude_pattern = utils.expand_template(self.exclude_pattern_option, { escaped })
      if not utils.is_excluded(exclude_pattern, s, init, start, end_) then
        return start, end_, rgb
      end
    end
  end
end

return CustomEntries.new
