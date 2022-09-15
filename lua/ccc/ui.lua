local api = vim.api

local set_hl = api.nvim_set_hl
local add_hl = api.nvim_buf_add_highlight

local Color = require("ccc.color")
local config = require("ccc.config")
local utils = require("ccc.utils")
local sa = require("ccc.utils.safe_array")

---@alias input_mode "RGB" | "HSL"
---@alias output_mode "RGB" | "HSL" | "HEX"

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
local UI = {}

function UI:init()
    self.input_mode = self.input_mode or config.get("default_input_mode")
    self.output_mode = self.output_mode or config.get("default_output_mode")
    if self.color == nil or not config.get("preserve") then
        self.color = Color.new(self.input_mode, self.output_mode)
    else
        self.color = self.color:copy()
    end
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
    self.win_height = 5
    self.ns_id = self.ns_id or api.nvim_create_namespace("ccc")
    self.row = utils.row()
    self.start_col = utils.col()
    self.prev_colors = self.prev_colors or {}
end

function UI:_open()
    local win_opts = config.get("win_opts")
    win_opts.height = self.win_height
    win_opts.width = self.win_width
    self.win_id = api.nvim_open_win(self.bufnr, true, win_opts)
end

---@param insert boolean
function UI:open(insert)
    if api.nvim_win_is_valid(self.win_id or -1) then
        return
    end

    self:init()
    self.is_insert = insert
    self:set_default_color()
    if insert then
        self.end_col = self.start_col - 1
        utils.feedkey("<Esc>")
    else
        self:pick()
    end
    self:update(true)
    self:_open()
    self:highlight()
    utils.cursor_set({ 2, 1 })
end

function UI:set_default_color()
    local default_color = config.get("default_color")
    local start, _, R, G, B = self.color:pick(default_color)
    assert(start, "Invalid color format: " .. default_color)
    self.color:set_rgb(R, G, B)
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
    if utils.row() == 6 then
        local line_to_cursor = api.nvim_get_current_line():sub(1, utils.col())
        local idx = math.floor(#line_to_cursor / 8) + 1
        local color = self.prev_colors[idx]
        if color.input.name ~= self.input_mode then
            local R, G, B = color:get_rgb()
            color:set_input(self.input_mode)
            color:set_rgb(R, G, B)
        end
        if color.output.name ~= self.output_mode then
            color:set_output(self.output_mode)
        end
        self.color = color
        self:hide_prev_colors()
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

---@param nohl? boolean
function UI:update(nohl)
    utils.set_lines(self.bufnr, 0, 5, self:buffer())
    if not nohl then
        self:highlight()
    end
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
    for i, v in ipairs({ self.color:get() }) do
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
    local v1, v2, v3 = self.color:get()
    local max = self.color.input.max

    local bar_char = config.get("bar_char")
    local point_char = config.get("point_char")
    local bar_len = config.get("bar_len")
    local point_idx_v1 = ratio(v1, max[1], bar_len)
    local point_idx_v2 = ratio(v2, max[2], bar_len)
    local point_idx_v3 = ratio(v3, max[3], bar_len)
    -- 7 is the lenght of ' : 000 '
    local start = sa.new(self.color.input.bar_name)
        :map(function(name)
            return api.nvim_strwidth(name)
        end)
        :max() + 7
    local start_v1, start_v2, start_v3 = start, start, start
    local end_v1, end_v2, end_v3
    for i = 0, bar_len - 1 do
        end_v1 = update_end(i == point_idx_v1, start_v1, #bar_char, #point_char)
        end_v2 = update_end(i == point_idx_v2, start_v2, #bar_char, #point_char)
        end_v3 = update_end(i == point_idx_v3, start_v3, #bar_char, #point_char)

        local hex_v1 = self.color:hex(utils.round((i + 0.5) * max[1] / bar_len), v2, v3)
        local hex_v2 = self.color:hex(v1, utils.round((i + 0.5) * max[2] / bar_len), v3)
        local hex_v3 = self.color:hex(v1, v2, utils.round((i + 0.5) * max[3] / bar_len))
        set_hl(0, "CccV1" .. i, { fg = hex_v1 })
        set_hl(0, "CccV2" .. i, { fg = hex_v2 })
        set_hl(0, "CccV3" .. i, { fg = hex_v3 })
        add_hl(0, self.ns_id, "CccV1" .. i, 1, start_v1, end_v1)
        add_hl(0, self.ns_id, "CccV2" .. i, 2, start_v2, end_v2)
        add_hl(0, self.ns_id, "CccV3" .. i, 3, start_v3, end_v3)

        start_v1, start_v2, start_v3 = end_v1, end_v2, end_v3
    end

    local output_bg = self.color:hex()
    local output_fg = output_bg > "#800000" and "#000000" or "#ffffff"
    set_hl(0, "CccOutput", { fg = output_fg, bg = output_bg })
    local start_output = api.nvim_buf_get_lines(self.bufnr, 4, 5, true)[1]:find("%S") - 1
    add_hl(0, self.ns_id, "CccOutput", 4, start_output, -1)

    if self.win_height == 6 then
        local start_prev, end_prev = 0, 7
        for i, color in ipairs(self.prev_colors) do
            local bg = color:hex()
            local fg = bg > "#800000" and "#000000" or "#ffffff"
            set_hl(0, "CccPrev" .. i, { fg = fg, bg = bg })
            add_hl(0, self.ns_id, "CccPrev" .. i, 5, start_prev, end_prev)
            start_prev = end_prev + 1
            end_prev = start_prev + 7
        end
    end
end

---@param delta integer
function UI:delta(delta)
    local v1, v2, v3 = self.color:get()
    local row = utils.row()
    if row == 2 then
        v1 = utils.fix_overflow(v1 + delta, 0, self.color.input.max[1])
    elseif row == 3 then
        v2 = utils.fix_overflow(v2 + delta, 0, self.color.input.max[2])
    elseif row == 4 then
        v3 = utils.fix_overflow(v3 + delta, 0, self.color.input.max[3])
    end
    self.color:set(v1, v2, v3)
    self:update()
end

function UI:set_percent(percent)
    local v1, v2, v3 = self.color:get()
    local row = utils.row()
    if row == 2 then
        v1 = utils.round(self.color.input.max[1] * percent / 100)
    elseif row == 3 then
        v2 = utils.round(self.color.input.max[2] * percent / 100)
    elseif row == 4 then
        v3 = utils.round(self.color.input.max[3] * percent / 100)
    end
    self.color:set(v1, v2, v3)
    self:update()
end

function UI:pick()
    ---@type string
    local current_line = api.nvim_get_current_line()
    local start, end_, R, G, B = self.color:pick(current_line)
    local cursor_col = utils.col()
    if start and start <= cursor_col and cursor_col <= end_ then
        self.start_col = start
        self.end_col = end_
        self.color:set_rgb(R, G, B)
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
    self.win_height = 6
    self:_open()

    local line = sa.new(self.prev_colors)
        :map(function(color)
            return color:str()
        end)
        :concat(" ")
    utils.set_lines(self.bufnr, 5, 6, { line })

    self.prev_pos = utils.cursor()
    utils.cursor_set({ 6, 1 })
    self:highlight()
end

function UI:hide_prev_colors()
    utils.set_lines(self.bufnr, 5, 6, {})
    self:_close()
    self.win_height = 5
    self:_open()
    utils.cursor_set(self.prev_pos)
end

function UI:toggle_prev_colors()
    if self.win_height == 5 then
        self:show_prev_colors()
    else
        self:hide_prev_colors()
    end
end

return UI
