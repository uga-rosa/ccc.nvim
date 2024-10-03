local utils = require("ccc.utils")

local M = {}

M.none = "<Plug>(ccc-none)"

---@param core ccc.Core
function M.complete(core)
  core:complete()
end

function M.quit()
  vim.cmd("quit")
end

---@param d integer
---@param core ccc.Core
function M._apply_delta(d, core)
  local point = core.ui:point_at()
  if point.type == "color" then
    local index = point.index
    local input = core.color:input()
    local value = input:get()[index]
    local delta = input.delta[index] * d
    local new_value = utils.clamp(value + delta, input.min[index], input.max[index])
    input:callback(index, new_value)
  elseif point.type == "alpha" then
    local value = core.color.alpha:get()
    if not value then
      return
    end
    local new_value = utils.clamp(value + d / 100, 0, 1)
    core.color.alpha:set(new_value)
  end
  core.ui:update()
  core:set_color()
end

for _, delta in ipairs({ 1, 5, 10 }) do
  M["increase" .. delta] = utils.bind(M._apply_delta, delta)
  M["decrease" .. delta] = utils.bind(M._apply_delta, -delta)
end

---@param percent number
---@param core ccc.Core
function M._set_percent(percent, core)
  local point = core.ui:point_at()
  if point.type == "color" then
    local index = point.index
    local input = core.color:input()
    local max, min = input.max[index], input.min[index]
    local new_value = (max - min) * percent / 100 + min
    input:callback(index, new_value)
  elseif point.type == "alpha" then
    local new_value = percent / 100
    core.color.alpha:set(new_value)
  end
  core.ui:update()
  core:set_color()
end

for _, percent in ipairs({ 0, 50, 100 }) do
  M["set" .. percent] = utils.bind(M._set_percent, percent)
end

---@param core ccc.Core
function M.show_alpha(core)
  core.color.alpha:show()
  core.ui:update()
end

---@param core ccc.Core
function M.hide_alpha(core)
  core.color.alpha:hide()
  core.ui:update()
end

---@param core ccc.Core
function M.reset_mode(core)
  core:reset_mode()
end

---@param core ccc.Core
function M.toggle_alpha(core)
  core.color.alpha:toggle()
  core.ui:update()
end

---@param core ccc.Core
function M.show_prev_colors(core)
  core.ui:toggle_prev_colors(true)
end

---@param core ccc.Core
function M.hide_prev_colors(core)
  core.ui:toggle_prev_colors(false)
end

---@param core ccc.Core
function M.toggle_prev_colors(core)
  core.ui:toggle_prev_colors()
end

---@param core ccc.Core
function M.goto_prev(core)
  core.prev_colors:delta(-1)
  core.ui:set_point({ type = "prev", index = core.prev_colors:get_index() })
end

---@param core ccc.Core
function M.goto_next(core)
  core.prev_colors:delta(1)
  core.ui:set_point({ type = "prev", index = core.prev_colors:get_index() })
end

---@param core ccc.Core
function M.goto_head(core)
  core.prev_colors:delta(-math.huge)
  core.ui:set_point({ type = "prev", index = core.prev_colors:get_index() })
end

---@param core ccc.Core
function M.goto_tail(core)
  core.prev_colors:delta(math.huge)
  core.ui:set_point({ type = "prev", index = core.prev_colors:get_index() })
end

---@param core ccc.Core
function M.toggle_input_mode(core)
  vim.notify_once("[ccc.nvim] toggle_input_mode is deprecated. Use cycle_input_mode instead.", vim.log.levels.WARN)
  M.cycle_input_mode(core)
end

---@param core ccc.Core
function M.cycle_input_mode(core)
  core.color:cycle_input()
  core.ui:update()
end

---@param core ccc.Core
function M.toggle_output_mode(core)
  vim.notify_once("[ccc.nvim] toggle_output_mode is deprecated. Use cycle_output_mode instead.", vim.log.levels.WARN)
  M.cycle_output_mode(core)
end

---@param core ccc.Core
function M.cycle_output_mode(core)
  core.color:cycle_output()
  core.ui:update()
end

return M
