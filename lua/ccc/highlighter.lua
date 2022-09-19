local api = vim.api
local fn = vim.fn

local config = require("ccc.config")
local utils = require("ccc.utils")
local hex = require("ccc.output.hex")

---@class Highlighter
---@field pickers ColorPicker[]
---@field ns_id integer
---@field aug_id integer
---@field ft_filter table<string, boolean>
---@field events string[]
---@field enabled boolean
local Highlighter = {}

function Highlighter:init()
    self.pickers = config.get("pickers")
    self.ns_id = api.nvim_create_namespace("ccc-highlighter")
    local highlighter_config = config.get("highlighter")
    ---@type string[]
    local filetypes = highlighter_config.filetypes
    local always_valid = #filetypes == 0
    local ft_filter = {}
    for _, v in ipairs(filetypes) do
        ft_filter[v] = true
    end
    self.ft_filter = setmetatable(ft_filter, {
        __index = function()
            return always_valid
        end,
    })
    self.events = highlighter_config.events
end

function Highlighter:enable()
    if self.pickers == nil then
        self:init()
    end
    self.enabled = true
    api.nvim_set_hl_ns(self.ns_id)

    self:update()
    self.aug_id = api.nvim_create_augroup("ccc-highlighter", {})
    api.nvim_create_autocmd(self.events, {
        group = self.aug_id,
        pattern = "*",
        callback = function()
            if self.ft_filter[vim.bo.filetype] then
                self:update()
            end
        end,
    })
end

function Highlighter:update()
    api.nvim_buf_clear_namespace(0, self.ns_id, 0, -1)
    local start_row = fn.line("w0") - 1
    local end_row = fn.line("w$")
    for i, line in ipairs(api.nvim_buf_get_lines(0, start_row, end_row, false)) do
        local row = start_row + i - 1
        local init = 1
        local max = 100
        local count = 0
        while true do
            count = count + 1
            if count > max then
                break
            end
            local start, end_, RGB
            for _, picker in ipairs(self.pickers) do
                start, end_, RGB = picker.parse_color(line, init)
                if start then
                    break
                end
            end
            if start == nil then
                break
            end
            ---@cast RGB number[]
            local hl_group = "CccHighlighter" .. row .. "_" .. start
            local bg = hex.str(RGB)
            local fg = utils.fg_hex(bg)
            api.nvim_set_hl(0, hl_group, { fg = fg, bg = bg })
            api.nvim_buf_add_highlight(0, self.ns_id, hl_group, row, start - 1, end_)
            init = end_ + 1
        end
    end
end

function Highlighter:disable()
    self.enabled = false
    api.nvim_buf_clear_namespace(0, self.ns_id, 0, -1)
    api.nvim_del_augroup_by_id(self.aug_id)
end

function Highlighter:toggle()
    if self.enabled then
        self:disable()
    else
        self:enable()
    end
end

return Highlighter
