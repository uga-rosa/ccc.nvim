local utils = require("ccc.utils")

---@class ccc.Core
---@field ui ccc.UI
---@field color ccc.Color
---@field prev_colors ccc.PrevColors
---@field range lsp.Range
local Core = {}
Core.__index = Core

function Core.new()
  local opts = require("ccc.config").options
  local self = setmetatable({
    ui = opts.ui.new(),
    color = require("ccc.color").new(),
    prev_colors = require("ccc.color.prev_colors").new(),
  }, Core)
  self.ui.on_quit_callback = utils.bind(self.on_quit, self)
  return self
end

--- Reset the mode of input/output, and hide alpha and prev_colors.
--- It does not initialize the color.
function Core:reset_mode()
  self.color:reset_mode()
  self.ui:reset_view()
end

function Core:pick()
  local opts = require("ccc.config").options
  ---@type integer?, integer?, RGB?, Alpha?, ccc.ColorInput?, ccc.ColorOutput?
  local start, end_, rgb, alpha, input, output
  if opts.lsp then
    start, end_, rgb, alpha = require("ccc.handler.lsp"):pick()
  end
  if start == nil then
    start, end_, rgb, alpha, input, output = require("ccc.handler.picker").pick()
  end
  if start and end_ and rgb then
    local row = utils.row()
    self.range = {
      start = { line = row - 1, character = start - 1 },
      ["end"] = { line = row - 1, character = end_ },
    }
    self.color:set_rgb(rgb)
  else
    local cursor = utils.cursor()
    local position = { line = cursor[1] - 1, character = cursor[2] - 1 }
    self.range = { start = position, ["end"] = position }
    self.color:reset()
  end
  if alpha then
    self.color.alpha:set(alpha)
  end
  if input then
    local index = self.color._inputs:findIndex(("x.name == %q"):format(input.name))
    if index > 0 then
      self.color._input_idx = index
    end
  end
  if output then
    local index = self.color._outputs:findIndex(("x.name == %q"):format(output.name))
    if index > 0 then
      self.color._output_idx = index
    end
  end
  self.ui:open(self.color, self.prev_colors)
  -- Key mappings
  for lhs, rhs in pairs(opts.mappings) do
    vim.keymap.set("n", lhs, utils.bind(rhs, self), { nowait = true, buffer = self.ui.bufnr })
  end
end

function Core:insert()
  self.color:reset()
  local cursor = utils.cursor()
  local position = { line = cursor[1] - 1, character = cursor[2] - 1 }
  self.range = { start = position, ["end"] = position }
  self.ui:open(self.color, self.prev_colors)
end

function Core:on_quit()
  local opts = require("ccc.config").options
  if opts.save_on_quit then
    self.prev_colors:prepend(self.color:copy())
  end
end

function Core:complete()
  local point = self.ui:point_at()
  if point.type == "prev" then
    self.prev_colors:get()
    return
  end
  self.prev_colors:prepend(self.color:copy())
  self.ui:close()
  vim.api.nvim_buf_set_text(
    0,
    self.range.start.line,
    self.range.start.character,
    self.range["end"].line,
    self.range["end"].character,
    { self.color:str() }
  )
end

return Core
