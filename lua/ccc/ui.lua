local api = vim.api
local fn = vim.fn

local function set_hl(ns_id, name, val)
    if val[vim.type_idx] then
        val[vim.type_idx] = nil
    end
    api.nvim_set_hl(ns_id, name, val)
end

local add_hl = api.nvim_buf_add_highlight

local Color = require("ccc.color")
local config = require("ccc.config")
local utils = require("ccc.utils")
local prev_colors = require("ccc.prev_colors")
local alpha = require("ccc.alpha")

---@class UI
---@field color CccColor
---@field input_mode string
---@field output_mode string
---@field pickers ColorPicker[]
---@field before_color CccColor #Picked color or default
---@field bufnr integer
---@field win_id integer
---@field win_height integer
---@field win_width integer
---@field ns_id integer
---@field row integer 1-index
---@field start_col integer 1-index
---@field end_col integer 1-index
---@field is_insert boolean
---@field alpha AlphaSlider
---@field prev_colors PrevColors
---@field highlighter_lsp boolean
---@field auto_close boolean
local UI = {}

function UI:init()
    if self.alpha ~= nil then
        return
    end

    self.alpha = alpha.new(self)
    self.color = Color.new(nil, nil, self.alpha)
    self.input_mode = self.color.input.name
    self.output_mode = self.color.output.name
    self.bufnr = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(self.bufnr, "buftype", "nofile")
    api.nvim_buf_set_option(self.bufnr, "modifiable", false)
    api.nvim_buf_set_option(self.bufnr, "filetype", "ccc-ui")
    local mappings = config.get("mappings")
    for lhs, rhs in pairs(mappings) do
        vim.keymap.set("n", lhs, rhs, { nowait = true, buffer = self.bufnr })
    end
    self.ns_id = api.nvim_create_namespace("ccc-ui")
    self.prev_colors = prev_colors.new(self)
    self.highlighter_lsp = config.get("highlighter").lsp
    self.auto_close = config.get("auto_close")
end

function UI:reset()
    if config.get("preserve") then
        self.color = self.color:copy()
    else
        self.color = Color.new(self.input_mode, self.output_mode, self.alpha)
        self:set_default_color()
    end
    self.win_height = 2 + #self.color.input.value
    if self.alpha.is_showed then
        self.win_height = self.win_height + 1
    end
    self.row = utils.row()
    self.start_col = utils.col()
end

function UI:set_default_color()
    local default_color = config.get("default_color")
    local _, _, RGB = require("ccc.picker.hex"):parse_color(default_color)
    assert(RGB, "default_color must be HEX format (#ffffff)")
    self.color:set_rgb(RGB)
end

function UI:_open()
    local win_opts = config.get("win_opts")
    win_opts.height = self.win_height
    win_opts.width = self.win_width
    self.win_id = api.nvim_open_win(self.bufnr, true, win_opts)
    api.nvim_win_set_option(self.win_id, "signcolumn", "no")
    api.nvim_win_set_hl_ns(self.win_id, self.ns_id)
    local float_normal = api.nvim_get_hl_by_name("CccFloatNormal", true)
    local float_border = api.nvim_get_hl_by_name("CccFloatBorder", true)
    set_hl(self.ns_id, "Normal", float_normal)
    set_hl(self.ns_id, "EndOfBuffer", float_normal)
    set_hl(self.ns_id, "FloatBorder", float_border)
end

---@param insert boolean
function UI:open(insert)
    self:init()
    if self.win_id and api.nvim_win_is_valid(self.win_id) then
        return
    end

    self:reset()
    self.is_insert = insert
    if insert then
        self.end_col = self.start_col - 1
        utils.feedkey("<Esc>")
    else
        self:pick()
    end
    self.before_color = self.color:copy()
    self:update()
    self:_open()
    utils.cursor_set({ 2, 1 })
    api.nvim_create_autocmd("WinClosed", {
        pattern = self.win_id .. "",
        callback = function()
            self:on_close(true)
        end,
        once = true,
    })
    if self.auto_close then
        api.nvim_create_autocmd("WinLeave", {
            buffer = self.bufnr,
            callback = function()
                api.nvim_win_close(self.win_id, false)
                self:on_close(true)
            end,
            once = true,
        })
    end
end

---@param from_autocmd boolean
function UI:on_close(from_autocmd)
    self.win_id = nil
    self:_set_color("")
    if self.is_insert then
        vim.cmd("startinsert")
    end
    if not from_autocmd or config.get("save_on_quit") then
        self.prev_colors:add(self.color)
    end
end

function UI:complete()
    if self.prev_colors.is_showed and utils.row() == self.win_height then
        local color = self.prev_colors:select()
        if color then
            self.color = color
            self:update()
        end
        return
    end
    api.nvim_win_close(self.win_id, true)
    self:on_close(false)
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

function UI:refresh()
    if self.win_id and api.nvim_win_is_valid(self.win_id) then
        api.nvim_win_set_height(self.win_id, self.win_height)
        api.nvim_win_set_width(self.win_id, self.win_width)
        fn.winrestview({ topline = 1 })
    end
end

function UI:update()
    local end_ = self.prev_colors.is_showed and -2 or -1
    local prev_width = self.win_width
    utils.set_lines(self.bufnr, 0, end_, self:buffer())
    self:highlight()
    if self.win_width ~= prev_width then
        self:refresh()
    end
    self:_set_color()
end

---@param color? string HEX format color or empty string ("")
function UI:_set_color(color)
    color = vim.F.if_nil(color, self.color:hex())
    vim.g.ccc_color = color
    vim.cmd("do User CccColorChanged")
end

---@param value number
---@param min number
---@param max number
---@param bar_len integer
---@return integer
local function ratio(value, min, max, bar_len)
    value = value - min
    max = max - min
    local r = utils.round(value / max * bar_len)
    if r == 0 then
        r = 1
    end
    return r
end

---@param value number
---@param min number
---@param max number
---@param bar_len integer
---@return string
local function create_bar(value, min, max, bar_len)
    local ratio_ = ratio(value, min, max, bar_len)
    local bar_char = config.get("bar_char")
    local point_char = config.get("point_char")
    if ratio_ == 0 then
        return point_char .. string.rep(bar_char, bar_len - 1)
    end
    return string.rep(bar_char, ratio_ - 1) .. point_char .. string.rep(bar_char, bar_len - ratio_)
end

---@return string[]
function UI:buffer()
    local buffer = {}

    local width
    local bar_len = config.get("bar_len")
    local input = self.color.input
    for i, v in ipairs(self.color:get()) do
        local line = input.bar_name[i]
            .. " : "
            .. input.format(v, i)
            .. " "
            .. create_bar(v, input.min[i], input.max[i], bar_len)
        buffer[i] = line
        if i == 1 then
            width = api.nvim_strwidth(line)
        end
    end
    self.win_width = width

    local mode = self.input_mode
    table.insert(buffer, 1, mode .. string.rep(" ", width - #mode))

    if self.alpha.is_showed then
        local line = "A"
            .. string.rep(" ", #input.bar_name[1] - 1)
            .. " : "
            .. self.alpha:str()
            .. " "
            .. create_bar(self.alpha:get(), 0, 1, bar_len)
        table.insert(buffer, line)
    end

    local output_line = config.get("output_line")(self.before_color, self.color, width)
    table.insert(buffer, output_line)

    self.win_height = #buffer
    if self.prev_colors.is_showed then
        self.win_height = self.win_height + 1
    end
    return buffer
end

---@param is_point boolean
---@param start integer
---@param bar_char_len integer
---@param point_char_len integer
---@return integer
local function update_end(is_point, start, bar_char_len, point_char_len)
    if is_point then
        return start + point_char_len
    else
        return start + bar_char_len
    end
end

function UI:highlight()
    api.nvim_buf_clear_namespace(self.bufnr, self.ns_id, 0, -1)

    local bar_char = config.get("bar_char")
    local point_char = config.get("point_char")
    local point_color = config.get("point_color")
    local bar_len = config.get("bar_len")
    local bar_name_len = #self.color.input.bar_name[1]
    -- The specification for ColorInput.format() specifies that it should be 6 bytes.
    local value_len = 6
    local row = 0
    for i, v in ipairs(self.color:get()) do
        row = row + 1

        local max = self.color.input.max[i]
        local min = self.color.input.min[i]
        local point_idx = ratio(v, min, max, bar_len)
        -- 3 means ' : ', 1 means ' '
        local start = bar_name_len + 3 + value_len + 1
        local end_
        for j = 1, bar_len do
            end_ = update_end(j == point_idx, start, #bar_char, #point_char)

            local hex
            if point_color ~= "" and j == point_idx then
                hex = point_color
            else
                local new_value = (j - 0.5) / bar_len * (max - min) + min
                hex = self.color:hex(i, new_value)
            end
            local color_name = "CccBar" .. i .. "_" .. j
            set_hl(self.ns_id, color_name, { fg = hex })
            add_hl(self.bufnr, self.ns_id, color_name, i, start, end_)

            start = end_
        end
    end

    if self.alpha.is_showed then
        row = row + 1
        local point_idx = ratio(self.alpha:get(), 0, 1, bar_len)
        local start = bar_name_len + 3 + value_len + 1
        local end_
        for i = 0, bar_len - 1 do
            end_ = update_end(i == point_idx, start, #bar_char, #point_char)

            local hex = self.alpha:hex((i + 0.5) / bar_len)
            local color_name = "CccAlpha" .. i
            set_hl(self.ns_id, color_name, { fg = hex })
            add_hl(self.bufnr, self.ns_id, color_name, row, start, end_)

            start = end_
        end
    end

    row = row + 1

    local hl_mode = config.get("highlight_mode")
    local _, b_start_col, b_end_col, a_start_col, a_end_col =
        config.get("output_line")(self.before_color, self.color, self.win_width)

    local before_hex = self.before_color:hex()
    set_hl(self.ns_id, "CccBefore", utils.create_highlight(before_hex, hl_mode))
    add_hl(self.bufnr, self.ns_id, "CccBefore", row, b_start_col, b_end_col)

    local after_hex = self.color:hex()
    set_hl(self.ns_id, "CccAfter", utils.create_highlight(after_hex, hl_mode))
    add_hl(self.bufnr, self.ns_id, "CccAfter", row, a_start_col, a_end_col)

    if self.prev_colors.is_showed then
        row = row + 1
        local start_prev, end_prev = 0, 7
        for i, color in ipairs(self.prev_colors.colors) do
            local pre_hex = color:hex()
            set_hl(self.ns_id, "CccPrev" .. i, utils.create_highlight(pre_hex, hl_mode))
            add_hl(self.bufnr, self.ns_id, "CccPrev" .. i, row, start_prev, end_prev)
            start_prev = end_prev + 1
            end_prev = start_prev + 7
        end
    end
end

---@param d integer
function UI:delta(d)
    local index = utils.row() - 1
    local input = self.color.input
    if 1 <= index and index <= #input.value then
        local value = input.value[index]
        local delta = input.delta[index] * d
        local new_value = utils.clamp(value + delta, input.min[index], input.max[index])
        input:callback(index, new_value)
    elseif self.alpha.is_showed and index == #input.value + 1 then
        local value = self.alpha:get()
        local new_value = utils.clamp(value + d / 100, 0, 1)
        self.alpha:set(new_value)
    else
        return
    end
    self:update()
end

function UI:set_percent(percent)
    local index = utils.row() - 1
    local input = self.color.input
    if 1 <= index and index <= #input.value then
        local max = input.max[index]
        local min = input.min[index]
        local new_value = (max - min) * percent / 100 + min
        input:callback(index, new_value)
    elseif self.alpha.is_showed and index == #input.value + 1 then
        local new_value = percent / 100
        self.alpha:set(new_value)
    else
        return
    end
    self:update()
end

function UI:pick()
    if self.highlighter_lsp then
        local start, end_, RGB, A = require("ccc.picker.lsp").pick()
        if start then
            ---@cast end_ integer
            ---@cast RGB RGB
            self.start_col = start
            self.end_col = end_
            self.color:set_rgb(RGB)
            self.before_color = self.color
            if A then
                self.alpha:set(A)
                self.alpha:show(true)
            end
            return
        end
    end

    local current_line = api.nvim_get_current_line()
    local cursor_col = utils.col()
    local init = 1
    while true do
        local start, end_, RGB, A
        for _, picker in ipairs(config.get("pickers")) do
            local s_, e_, rgb, a = picker:parse_color(current_line, init)
            if s_ and (start == nil or s_ < start) then
                start = s_
                end_ = e_
                RGB = rgb
                A = a
            end
        end
        if start == nil then
            break
        end
        if start <= cursor_col and cursor_col <= end_ then
            ---@cast end_ integer
            ---@cast RGB RGB
            self.start_col = start
            self.end_col = end_
            self.color:set_rgb(RGB)
            self.before_color = self.color
            if A then
                self.alpha:set(A)
                self.alpha:show(true)
            end
            return
        end
        init = end_ + 1
    end
    self.end_col = self.start_col - 1
end

function UI:toggle_input_mode()
    self.color:toggle_input()
    self.input_mode = self.color.input.name
    self:update()
    self:refresh()
end

function UI:toggle_output_mode()
    self.color:toggle_output()
    self.output_mode = self.color.output.name
    self:update()
end

return UI
