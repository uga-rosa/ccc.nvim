local utils = require("ccc.utils")
local sa = require("ccc.utils.safe_array")

---@class PrevColors
---@field ui UI
---@field colors Color[]
---@field selected_color Color
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

---@param color Color
function PrevColors:add(color)
    table.insert(self.colors, 1, color)
    self.selected_color = color
    self.index = 1
end

function PrevColors:get()
    return self.selected_color
end

---@return Color?
function PrevColors:select()
    if not self:get() then
        return
    end
    local color = self:get():copy()
    if color.input.name ~= self.ui.input_mode then
        local RGB = color:get_rgb()
        color:set_input(self.ui.input_mode)
        color:set_rgb(RGB)
    end
    if color.output.name ~= self.ui.output_mode then
        color:set_output(self.ui.output_mode)
    end
    self:hide()
    return color
end

function PrevColors:show()
    self.is_showed = true
    local ui = self.ui
    ui.win_height = ui.win_height + 1
    ui:refresh()

    local line = sa.new(self.colors)
        :map(function(color)
            return color:hex()
        end)
        :concat(" ")
    utils.set_lines(ui.bufnr, ui.win_height - 1, ui.win_height, { line })

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
    utils.cursor_set(self.prev_pos)
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
