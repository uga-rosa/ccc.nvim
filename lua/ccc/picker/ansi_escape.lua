local parse = require("ccc.utils.parse")

local definition = {
  code2name = {
    ["\\u001b[30m"] = { "black", "fg" },
    ["\\u001b[31m"] = { "red", "fg" },
    ["\\u001b[32m"] = { "green", "fg" },
    ["\\u001b[33m"] = { "yellow", "fg" },
    ["\\u001b[34m"] = { "blue", "fg" },
    ["\\u001b[35m"] = { "magenta", "fg" },
    ["\\u001b[36m"] = { "cyan", "fg" },
    ["\\u001b[37m"] = { "white", "fg" },
    ["\\u001b[30;1m"] = { "bright_black", "fg" },
    ["\\u001b[31;1m"] = { "bright_red", "fg" },
    ["\\u001b[32;1m"] = { "bright_green", "fg" },
    ["\\u001b[33;1m"] = { "bright_yellow", "fg" },
    ["\\u001b[34;1m"] = { "bright_blue", "fg" },
    ["\\u001b[35;1m"] = { "bright_magenta", "fg" },
    ["\\u001b[36;1m"] = { "bright_cyan", "fg" },
    ["\\u001b[37;1m"] = { "bright_white", "fg" },
    ["\\u001b[40m"] = { "black", "bg" },
    ["\\u001b[41m"] = { "red", "bg" },
    ["\\u001b[42m"] = { "green", "bg" },
    ["\\u001b[43m"] = { "yellow", "bg" },
    ["\\u001b[44m"] = { "blue", "bg" },
    ["\\u001b[45m"] = { "magenta", "bg" },
    ["\\u001b[46m"] = { "cyan", "bg" },
    ["\\u001b[47m"] = { "white", "bg" },
    ["\\u001b[40;1m"] = { "bright_black", "bg" },
    ["\\u001b[41;1m"] = { "bright_red", "bg" },
    ["\\u001b[42;1m"] = { "bright_green", "bg" },
    ["\\u001b[43;1m"] = { "bright_yellow", "bg" },
    ["\\u001b[44;1m"] = { "bright_blue", "bg" },
    ["\\u001b[45;1m"] = { "bright_magenta", "bg" },
    ["\\u001b[46;1m"] = { "bright_cyan", "bg" },
    ["\\u001b[47;1m"] = { "bright_white", "bg" },
  },
}

---@class AnsiEscapePicker: ColorPicker
---@field name2color { [string]: string }
---@field pattern string
local AnsiEscapePicker = {
  pattern = [[\v\\u001b\[[34][0-7]%(;1)?m]],
}

---@param name2color { [string]: string }
---@return AnsiEscapePicker
function AnsiEscapePicker.new(name2color)
  return setmetatable({
    name2color = name2color,
  }, { __index = AnsiEscapePicker })
end

---@param s string
---@param init? integer
---@return integer? start
---@return integer? end_
---@return RGB?
---@return Alpha?
---@return hl_mode?
function AnsiEscapePicker:parse_color(s, init)
  init = vim.F.if_nil(init, 1)
  -- The shortest patten is 10 characters like `\u001b[30m`
  while init <= #s - 9 do
    local code, start, end_ = unpack(vim.fn.matchstrpos(s, self.pattern, init))
    if start == -1 then
      return
    end
    local name, hl_mode = unpack(definition.code2name[code])
    if name then
      local color = self.name2color[name]
      local R = parse.hex(color:sub(2, 3))
      local G = parse.hex(color:sub(4, 5))
      local B = parse.hex(color:sub(6, 7))
      return start, end_, { R, G, B }, nil, hl_mode
    end
    init = end_ + 1
  end
end

return AnsiEscapePicker.new
