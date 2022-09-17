local UI = require("ccc.ui")
local config = require("ccc.config")

local M = {
    inputs = {
        rgb = require("ccc.input.rgb"),
        hsl = require("ccc.input.hsl"),
        cmyk = require("ccc.input.cmyk"),
        lab = require("ccc.input.lab"),
        hsluv = require("ccc.input.hsluv"),
        xyz = require("ccc.input.xyz"),
    },
    outputs = {
        hex = require("ccc.output.hex"),
        hex_short = require("ccc.output.hex_short"),
        css_rgb = require("ccc.output.css_rgb"),
        css_hsl = require("ccc.output.css_hsl"),
    },
    pickers = {
        hex = require("ccc.picker.hex"),
        hex_short = require("ccc.picker.hex_short"),
        css_rgb = require("ccc.picker.css_rgb"),
        css_hsl = require("ccc.picker.css_hsl"),
    },
    mapping = {},
}

local ready = false

---@param opt table
---@overload fun(from_plugin: boolean)
function M.setup(opt)
    if opt == true then
        if ready == true then
            return
        end
        opt = {}
    end
    vim.validate({ opt = { opt, "t" } })
    config.setup(opt)
    ready = true
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
    UI:quit()
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

return M
