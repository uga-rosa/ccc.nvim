local api = vim.api

local config = require("ccc.config")
local utils = require("ccc.utils")

---@class Convert
---@field convert {[1]: ColorPicker, [2]: ColorOutput}[]
local Convert = {}

function Convert:init()
    self.convert = config.get("convert")
end

function Convert:toggle()
    if self.convert == nil then
        self:init()
    end
    local line = api.nvim_get_current_line()
    local cursor_col = utils.col()
    for _, v in ipairs(self.convert) do
        local picker, output = unpack(v)

        local init = 1
        local start, end_, rgb
        while true do
            start, end_, rgb = picker.parse_color(line, init)
            if start == nil then
                break
            elseif start <= cursor_col and cursor_col <= end_ then
                local new_line = line:sub(1, start - 1) .. output.str(rgb) .. line:sub(end_ + 1)
                api.nvim_set_current_line(new_line)
                return
            end
            init = end_ + 1
        end
    end
end

return Convert
