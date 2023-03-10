local UI = require("ccc.ui")
local config = require("ccc.config")
local utils = require("ccc.utils")

local M = {
  input = {
    rgb = require("ccc.input.rgb"),
    hsl = require("ccc.input.hsl"),
    hwb = require("ccc.input.hwb"),
    lab = require("ccc.input.lab"),
    lch = require("ccc.input.lch"),
    oklab = require("ccc.input.oklab"),
    oklch = require("ccc.input.oklch"),
    cmyk = require("ccc.input.cmyk"),
    hsluv = require("ccc.input.hsluv"),
    okhsl = require("ccc.input.okhsl"),
    hsv = require("ccc.input.hsv"),
    okhsv = require("ccc.input.okhsv"),
    xyz = require("ccc.input.xyz"),
  },
  output = {
    hex = require("ccc.output.hex"),
    hex_short = require("ccc.output.hex_short"),
    css_rgb = require("ccc.output.css_rgb"),
    css_hsl = require("ccc.output.css_hsl"),
    css_hwb = require("ccc.output.css_hwb"),
    css_lab = require("ccc.output.css_lab"),
    css_lch = require("ccc.output.css_lch"),
    css_oklab = require("ccc.output.css_oklab"),
    css_oklch = require("ccc.output.css_oklch"),
    float = require("ccc.output.float"),
  },
  picker = {
    css_rgb = require("ccc.picker.css_rgb"),
    css_name = require("ccc.picker.css_name"),
    hex = require("ccc.picker.hex"),
    css_hsl = require("ccc.picker.css_hsl"),
    css_hwb = require("ccc.picker.css_hwb"),
    css_lab = require("ccc.picker.css_lab"),
    css_lch = require("ccc.picker.css_lch"),
    css_oklab = require("ccc.picker.css_oklab"),
    css_oklch = require("ccc.picker.css_oklch"),
    custom_entries = require("ccc.picker.custom_entries"),
  },
  mapping = {},
}

setmetatable(M, {
  __index = function(self, key)
    if key == "inputs" or key == "outputs" or key == "pickers" then
      local properer_key = key:sub(1, -2)
      utils.notify("ccc.%s is deprecated. Use ccc.%s instead.", key, properer_key)
      return self[properer_key]
    end
  end,
})

---@param opt? table
function M.setup(opt)
  opt = vim.F.if_nil(opt, {})
  vim.validate({ opt = { opt, "t" } })

  config.setup(opt)
end

---@param b_color CccColor
---@param a_color CccColor
---@param width integer
---@return string line
---@return integer b_start_col
---@return integer b_end_col
---@return integer a_start_col
---@return integer a_end_col
function M.output_line(b_color, a_color, width)
  local b_hex = b_color:hex()
  local a_str = a_color:str()
  local line = b_hex .. " =>" .. string.rep(" ", width - #b_hex - #a_str - 3) .. a_str

  local b_start_col = 0
  local b_end_col = #b_hex
  local a_start_col = width - #a_str
  local a_end_col = -1
  return line, b_start_col, b_end_col, a_start_col, a_end_col
end

---@param delta integer
function M.delta(delta)
  UI:delta(delta)
end

---@param percent integer
function M.set_percent(percent)
  UI:set_percent(percent)
end

function M.mapping.quit()
  vim.cmd("quit")
end

function M.mapping.complete()
  UI:complete()
end

function M.mapping.toggle_input_mode()
  UI:toggle_input_mode()
end

function M.mapping.toggle_output_mode()
  UI:toggle_output_mode()
end

function M.mapping.show_alpha()
  UI.alpha:show()
end

function M.mapping.hide_alpha()
  UI.alpha:hide()
end

function M.mapping.toggle_alpha()
  UI.alpha:toggle()
end

function M.mapping.show_prev_colors()
  UI.prev_colors:show()
end

function M.mapping.hide_prev_colors()
  UI.prev_colors:hide()
end

function M.mapping.toggle_prev_colors()
  UI.prev_colors:toggle()
end

function M.mapping.goto_prev()
  UI.prev_colors:goto_prev()
end

function M.mapping.goto_next()
  UI.prev_colors:goto_next()
end

function M.mapping.goto_head()
  UI.prev_colors:goto_head()
end

function M.mapping.goto_tail()
  UI.prev_colors:goto_tail()
end

function M.mapping.increase1()
  M.delta(1)
end

function M.mapping.increase5()
  M.delta(5)
end

function M.mapping.increase10()
  M.delta(10)
end

function M.mapping.decrease1()
  M.delta(-1)
end

function M.mapping.decrease5()
  M.delta(-5)
end

function M.mapping.decrease10()
  M.delta(-10)
end

function M.mapping.set0()
  M.set_percent(0)
end

function M.mapping.set50()
  M.set_percent(50)
end

function M.mapping.set100()
  M.set_percent(100)
end

-- Disable only some of the default mappings
M.mapping.none = "<Plug>(ccc-none)"

return M
