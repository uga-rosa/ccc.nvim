local UI = require("ccc.ui")
local config = require("ccc.config")

local M = {
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
    UI:show_prev_colors()
end

function M.mapping.hide_prev_colors()
    UI:hide_prev_colors()
end

function M.mapping.toggle_prev_colors()
    UI:toggle_prev_colors()
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
