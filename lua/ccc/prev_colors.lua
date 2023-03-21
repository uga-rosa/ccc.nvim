local utils = require("ccc.utils")

---@class PrevColors
---@field ui UI
---@field colors CccColor[]
---@field selected_color CccColor
---@field index integer
---@field is_showed boolean
---@field prev_pos integer[] #(1,1)-index
local PrevColors = {}

---@param ui UI
---@return PrevColors
function PrevColors.new(ui)
  local new = setmetatable({
    ui = ui,
    colors = {},
    index = 1,
  }, { __index = PrevColors })
  return new
end

---@param color CccColor
function PrevColors:add(color)
  table.insert(self.colors, 1, color)
  self.selected_color = color
  self.index = 1
end

function PrevColors:get()
  return self.selected_color
end

function PrevColors:reset()
  self.colors = {}
  self.selected_color = nil
  self.index = 1
end

---@return CccColor?
function PrevColors:select()
  if not self:get() then
    return
  end
  local color = self:get():copy()
  local RGB = color:get_rgb()
  color:set_input(self.ui.input_mode)
  color:set_rgb(RGB)
  color:set_output(self.ui.output_mode)
  self:hide()
  return color
end

function PrevColors:show()
  self.is_showed = true
  local ui = self.ui
  ui.win_height = ui.win_height + 1
  ui:refresh()

  local colors = {}
  for i, color in ipairs(self.colors) do
    colors[i] = color:hex()
  end

  utils.set_lines(ui.bufnr, ui.win_height - 1, ui.win_height, { table.concat(colors, " ") })

  self.prev_pos = utils.cursor()
  if self:get() then
    self:_goto()
  else
    utils.cursor_set({ ui.win_height, 1 })
  end
  ui:highlight()
end

function PrevColors:hide()
  self.is_showed = false
  local ui = self.ui
  utils.set_lines(ui.bufnr, ui.win_height - 1, ui.win_height, {})
  ui.win_height = ui.win_height - 1
  ui:refresh()
  if self.prev_pos then
    utils.cursor_set(self.prev_pos)
  end
end

function PrevColors:toggle()
  if self.is_showed then
    self:hide()
  else
    self:show()
  end
end

function PrevColors:_goto()
  self.selected_color = self.colors[self.index]
  utils.cursor_set({ self.ui.win_height, self.index * 8 - 7 })
end

function PrevColors:goto_next()
  if self.index >= #self.colors then
    return
  end
  self.index = self.index + 1
  self:_goto()
end

function PrevColors:goto_prev()
  if self.index <= 1 then
    return
  end
  self.index = self.index - 1
  self:_goto()
end

function PrevColors:goto_tail()
  if self.index >= #self.colors then
    return
  end
  self.index = #self.colors
  self:_goto()
end

function PrevColors:goto_head()
  if self.index <= 1 then
    return
  end
  self.index = 1
  self:_goto()
end

return PrevColors
