local UI = require("ccc.ui")
local config = require("ccc.config")

local M = {
    mapping = {},
}

---@param opt? table
function M.setup(opt)
    opt = vim.F.if_nil(opt, {})
    vim.validate({ opt = { opt, "t" } })
    config.setup(opt)
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

function M.mapping.input_mode_toggle()
    UI:input_mode_toggle()
end

function M.mapping.output_mode_toggle()
    UI:output_mode_toggle()
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
