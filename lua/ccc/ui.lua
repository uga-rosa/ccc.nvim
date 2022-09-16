local api = vim.api

local set_hl = api.nvim_set_hl
local add_hl = api.nvim_buf_add_highlight

local Color = require("ccc.color")
local config = require("ccc.config")
local utils = require("ccc.utils")
local sa = require("ccc.utils.safe_array")

---@class UI
---@field color Color
---@field pickers ColorPicker[]
---@field bufnr integer
---@field win_id integer
---@field win_height integer
---@field win_width integer
---@field ns_id integer
---@field row integer 1-index
---@field start_col integer 1-index
---@field end_col integer 1-index
---@field prev_pos integer[] (1,1)-index
---@field is_insert boolean
---@field prev_colors Color[]
---@field is_showed boolean
local UI = {}

function UI:init()
    self.input_mode = self.input_mode or config.get("default_input_mode")
    self.output_mode = self.output_mode or config.get("default_output_mode")
    if self.color == nil or not config.get("preserve") then
        self.color = Color.new(self.input_mode, self.output_mode)
    else
        self.color = self.color:copy()
    end
    self:set_default_color()
    self.win_height = 2 + #self.color.input.value
    if self.bufnr == nil then
        self.bufnr = api.nvim_create_buf(false, true)
        api.nvim_buf_set_option(self.bufnr, "buftype", "nofile")
        api.nvim_buf_set_option(self.bufnr, "modifiable", false)
        api.nvim_buf_set_option(self.bufnr, "filetype", "ccc-ui")
        local mappings = config.get("mappings")
        for lhs, rhs in pairs(mappings) do
            vim.keymap.set("n", lhs, rhs, { nowait = true, buffer = self.bufnr })
        end
    end
    if self.ns_id == nil then
        self.ns_id = api.nvim_create_namespace("ccc")
    end
    self.row = utils.row()
    self.start_col = utils.col()
    self.prev_colors = self.prev_colors or {}
end

function UI:_open()
    local win_opts = config.get("win_opts")
    win_opts.height = self.win_height
    win_opts.width = self.win_width
    self.win_id = api.nvim_open_win(self.bufnr, true, win_opts)
    api.nvim_win_set_hl_ns(self.win_id, self.ns_id)
end

---@param insert boolean
function UI:open(insert)
    if api.nvim_win_is_valid(self.win_id or -1) then
        return
    end

    self:init()
    self.is_insert = insert
    if insert then
        self.end_col = self.start_col - 1
        utils.feedkey("<Esc>")
    else
        self:pick()
    end
    self:update()
    self:_open()
    utils.cursor_set({ 2, 1 })
end

function UI:set_default_color()
    local default_color = config.get("default_color")
    local start, _, RGB = self.color:pick(default_color)
    assert(start, "Invalid color format: " .. default_color)
    self.color:set_rgb(RGB)
end

function UI:_close()
    api.nvim_win_close(self.win_id, true)
end

function UI:close()
    if not api.nvim_win_is_valid(self.win_id) then
        return
    end
    self:_close()
    if self.is_insert then
        vim.cmd("startinsert")
    end
end

function UI:quit()
    self:close()
    if config.get("save_on_quit") then
        table.insert(self.prev_colors, 1, self.color)
    end
end

function UI:complete()
    if self.is_showed and self.win_height == utils.col() then
        local line_to_cursor = api.nvim_get_current_line():sub(1, utils.col())
        local idx = math.floor(#line_to_cursor / 8) + 1
        local color = self.prev_colors[idx]
        if color.input.name ~= self.input_mode then
            local RGB = color:get_rgb()
            color:set_input(self.input_mode)
            color:set_rgb(RGB)
        end
        if color.output.name ~= self.output_mode then
            color:set_output(self.output_mode)
        end
        self.color = color
        self:hide_prev_colors()
        self:update()
        return
    end
    self:close()
    table.insert(self.prev_colors, 1, self.color)
    if self.is_insert then
        utils.feedkey(self.color:str(), true)
    else
        local line = api.nvim_get_current_line()
        local new_line = line:sub(1, self.start_col - 1)
            .. self.color:str()
            .. line:sub(self.end_col + 1)
        api.nvim_set_current_line(new_line)
    end
end

function UI:update()
    utils.set_lines(self.bufnr, 0, self.is_showed and -2 or -1, self:buffer())
    self:highlight()
end

local function update_end(is_point, start, bar_char_len, point_char_len)
    if is_point then
        return start + point_char_len
    else
        return start + bar_char_len
    end
end

local function ratio(value, max, bar_len)
    return utils.round(value / max * bar_len)
end

local function create_bar(value, max, bar_len)
    local ratio_ = ratio(value, max, bar_len)
    local bar_char = config.get("bar_char")
    local point_char = config.get("point_char")
    if ratio_ == 0 then
        return point_char .. string.rep(bar_char, bar_len - 1)
    end
    return string.rep(bar_char, ratio_ - 1) .. point_char .. string.rep(bar_char, bar_len - ratio_)
end

function UI:buffer()
    local bar_len = config.get("bar_len")
    local color = self.color:str()

    local buffer = { self.input_mode }
    local width
    for i, v in ipairs(self.color:get()) do
        local row = {
            self.color.input.bar_name[i],
            ":",
            ("%3d"):format(v),
            create_bar(v, self.color.input.max[i], bar_len),
        }
        local line = table.concat(row, " ")
        table.insert(buffer, line)
        width = api.nvim_strwidth(line)
    end
    self.win_width = width
    local line = string.rep(" ", width - #color) .. color
    table.insert(buffer, line)
    return buffer
end

function UI:highlight()
    api.nvim_buf_clear_namespace(self.bufnr, self.ns_id, 0, -1)
    local value = self.color:get()

    local bar_char = config.get("bar_char")
    local point_char = config.get("point_char")
    local bar_len = config.get("bar_len")
    for i, v in ipairs(value) do
        local max = self.color.input.max[i]
        local point_idx = ratio(v, max, bar_len)
        -- 7 is the length of ' : 000 '
        local start = sa.new(self.color.input.bar_name)
            :map(function(name)
                return api.nvim_strwidth(name)
            end)
            :max() + 7
        local end_
        for j = 0, bar_len - 1 do
            end_ = update_end(j == point_idx, start, #bar_char, #point_char)

            local _value = { unpack(value) }
            _value[i] = utils.round((j + 0.5) * max / bar_len)
            local hex = self.color:hex(_value)
            local color_name = "CccBar" .. i .. "_" .. j
            set_hl(self.ns_id, color_name, { fg = hex })
            add_hl(self.bufnr, self.ns_id, color_name, i, start, end_)

            start = end_
        end
    end

    local output_row = #value + 1
    local output_bg = self.color:hex()
    local output_fg = output_bg > "#800000" and "#000000" or "#ffffff"
    set_hl(self.ns_id, "CccOutput", { fg = output_fg, bg = output_bg })
    local start_output = api.nvim_buf_get_lines(self.bufnr, output_row, output_row + 1, true)[1]
        :find("%S") - 1
    add_hl(self.bufnr, self.ns_id, "CccOutput", output_row, start_output, -1)

    local pre_row = output_row + 1
    if self.win_height == pre_row + 1 then
        local start_prev, end_prev = 0, 7
        for i, color in ipairs(self.prev_colors) do
            local bg = color:hex()
            local fg = bg > "#800000" and "#000000" or "#ffffff"
            set_hl(self.ns_id, "CccPrev" .. i, { fg = fg, bg = bg })
            add_hl(self.bufnr, self.ns_id, "CccPrev" .. i, pre_row, start_prev, end_prev)
            start_prev = end_prev + 1
            end_prev = start_prev + 7
        end
    end
end

---@param delta integer
function UI:delta(delta)
    local value = self.color:get()
    local idx = utils.row() - 1
    value[idx] = utils.fix_overflow(value[idx] + delta, 0, self.color.input.max[idx])
    self.color:set(value)
    self:update()
end

function UI:set_percent(percent)
    local value = self.color:get()
    local idx = utils.row() - 1
    value[idx] = utils.round(self.color.input.max[idx] * percent / 100)
    self.color:set(value)
    self:update()
end

function UI:pick()
    ---@type string
    local current_line = api.nvim_get_current_line()
    local start, end_, RGB = self.color:pick(current_line)
    local cursor_col = utils.col()
    if start and start <= cursor_col and cursor_col <= end_ then
        self.start_col = start
        self.end_col = end_
        self.color:set_rgb(RGB)
    else
        self.end_col = self.start_col - 1
    end
end

function UI:toggle_input_mode()
    self.color:toggle_input()
    self.input_mode = self.color.input.name
    self:update()
end

function UI:toggle_output_mode()
    self.color:toggle_output()
    self.output_mode = self.color.output.name
    self:update()
end

function UI:show_prev_colors()
    self:_close()
    self.win_height = self.win_height + 1
    self:_open()

    local line = sa.new(self.prev_colors)
        :map(function(color)
            return color:str()
        end)
        :concat(" ")
    utils.set_lines(self.bufnr, self.win_height - 1, self.win_height, { line })

    self.prev_pos = utils.cursor()
    utils.cursor_set({ self.win_height, 1 })
    self:highlight()
    self.is_showed = true
end

function UI:hide_prev_colors()
    utils.set_lines(self.bufnr, self.win_height - 1, self.win_height, {})
    self:_close()
    self.win_height = self.win_height - 1
    self:_open()
    utils.cursor_set(self.prev_pos)
    self.is_showed = false
end

function UI:toggle_prev_colors()
    if self.is_showed then
        self:hide_prev_colors()
    else
        self:show_prev_colors()
    end
end

return UI
