local config = require("ccc.config")
local utils = require("ccc.utils")
local parse = require("ccc.utils.parse")

---@class CustomTable: ColorPicker
---@field rgb { [string]: integer[] }
---@field re { match_str: function } vim.regex instance
---@field min_length integer
local CustomTable = {}

---@param color_table { [string]: string }
---@return CustomTable
CustomTable.new = function(color_table)
  local self = { rgb = {} }
  ---@type string[]
  local names = {}
  for name, rgb in pairs(color_table) do
    local r, g, b = rgb:match("(%x%x)(%x%x)(%x%x)")
    if r then
      table.insert(names, name)
      self.rgb[name] = { parse.hex(r), parse.hex(g), parse.hex(b) }
    end
  end
  table.sort(names, function(a, b)
    return #a > #b
  end)
  self.min_length = #names[#names]
  self.pattern = { [[\<]] .. table.concat(names, [[\|]]) .. [[\>]] }
  self.re = vim.regex(self.pattern[1])
  local ex_pat = config.get("exclude_pattern")
  self.exclude_pattern = utils.expand_template(ex_pat.custom_table, self.pattern)
  return setmetatable(self, { __index = CustomTable })
end

-- dummy
function CustomTable:init() end

---@param s string
---@param init? integer
---@return integer? start
---@return integer? end_
---@return number[]? RGB
---@return number? alpha
function CustomTable:parse_color(s, init)
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
      if not utils.is_excluded(self.exclude_pattern, s, init, start, end_) then
        return start, end_, rgb
      end
    end
  end
end

return CustomTable.new
