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
---@field input_mode input_mode
---@field output_mode output_mode
---@field bufnr integer
---@field win_id integer
---@field win_height integer
---@field win_width integer
---@field ns_id integer
---@field row integer 1-index
---@field start_col integer 1-index
---@field end_col integer 1-index
---@field is_insert boolean
---@field already_open boolean
---@field prev_colors Color[]
local UI = {}

function UI:init()
    self.input_mode = self.input_mode or config.get("default_input_mode")
    self.output_mode = self.output_mode or config.get("default_output_mode")
    if self.color == nil or not config.get("preserve") then
        self.color = Color.new(self.input_mode)
    else
        self.color = self.color:copy()
    end
    self.prev_colors = self.prev_colors or {}
    self.win_height = 4
    self.ns_id = self.ns_id or api.nvim_create_namespace("ccc")
    local cursor_pos = utils.cursor()
    self.row = cursor_pos[1]
    self.start_col = cursor_pos[2] + 1
    self.end_col = cursor_pos[2]
end

function UI:_open()
    if self.bufnr == nil then
        self.bufnr = api.nvim_create_buf(false, true)
    end
    self.win_width = 7 + config.get("bar_len")
    local win_opts = config.get("win_opts")
    win_opts.height = self.win_height
    win_opts.width = self.win_width
    self.win_id = api.nvim_open_win(self.bufnr, true, win_opts)
    vim.opt_local.buftype = "nofile"
    vim.opt_local.modifiable = false
end

---@param insert boolean
function UI:open(insert)
    if self.already_open then
        return
    end
    self.already_open = true
    self.is_insert = insert
    self:init()
    if not insert then
        self:pick()
    end
    self:_open()
    self:update()

    local mappings = config.get("mappings")
    for lhs, rhs in pairs(mappings) do
        vim.keymap.set("n", lhs, rhs, { nowait = true, buffer = self.bufnr })
    end
    if insert then
        utils.feedkey("<Esc>")
    end
end

function UI:_close()
    if self.win_id == nil then
        return
    end
    api.nvim_win_close(self.win_id, true)
end

function UI:close()
    if not self.already_open then
        return
    end
    local mappings = config.get("mappings")
    for lhs, _ in pairs(mappings) do
        vim.keymap.del("n", lhs, { buffer = self.bufnr })
    end
    self:_close()
    if self.is_insert then
        vim.cmd("startinsert")
    end
    api.nvim_win_set_cursor(0, { self.row, self.start_col - 1 })
    self.already_open = false
end

function UI:show_prev_colors()
    self:_close()
    self.win_height = 5
    self:_open()

    local line = sa.new(self.prev_colors)
        :map(function(color)
            return color:hex_str()
        end)
        :concat(" ")
    utils.set_lines(0, 4, 5, { line })

    local start, end_ = 0, 7
    for i, color in ipairs(self.prev_colors) do
        local bg = color:hex_str()
        local fg = bg > "#800000" and "#000000" or "#ffffff"
        set_hl(0, "CccPrev" .. i, { fg = fg, bg = bg })
        add_hl(0, self.ns_id, "CccPrev" .. i, 4, start, end_)
        start = end_ + 1
        end_ = start + 7
    end
    api.nvim_win_set_cursor(0, { 5, 0 })
end

function UI:hide_prev_colors()
    utils.set_lines(0, 0, 5, {})
    self:_close()
    self.win_height = 4
    self:_open()
    self:update()
end

function UI:toggle_prev_colors()
    if self.win_height == 4 then
        self:show_prev_colors()
    else
        self:hide_prev_colors()
    end
end

function UI:quit()
    self:close()
    if config.get("save_on_quit") then
        table.insert(self.prev_colors, 1, self.color)
    end
end

function UI:complete()
    if utils.row() == 5 then
        local line_to_cursor = api.nvim_get_current_line():sub(1, utils.col())
        local idx = math.floor(#line_to_cursor / 8) + 1
        local color = self.prev_colors[idx]
        self.color = color
        self:hide_prev_colors()
        return
    end
    self:close()
    table.insert(self.prev_colors, 1, self.color)
    if self.is_insert then
        self:insert()
    else
        self:replace()
    end
end

function UI:insert()
    utils.feedkey(self:output(), true)
end

function UI:replace()
    local line = api.nvim_get_current_line()
    local new_line = line:sub(1, self.start_col - 1) .. self:output() .. line:sub(self.end_col + 1)
    api.nvim_set_current_line(new_line)
end

local function update_end(is_point, start, bar_char_len, point_char_len)
    if is_point then
        return start + point_char_len
    else
        return start + bar_char_len
    end
end

function UI:highlight()
    local v1, v2, v3, max1, max2, max3
    if self.input_mode == "RGB" then
        v1, v2, v3 = self.color:get_rgb()
        max1, max2, max3 = 255, 255, 255
    else
        v1, v2, v3 = self.color:get_hsl()
        max1, max2, max3 = 360, 100, 100
    end

    local bar_char = config.get("bar_char")
    local point_char = config.get("point_char")
    local bar_len = config.get("bar_len")
    local point_idx_v1 = utils.ratio(v1, max1, bar_len)
    local point_idx_v2 = utils.ratio(v2, max2, bar_len)
    local point_idx_v3 = utils.ratio(v3, max3, bar_len)
    local start_v1, start_v2, start_v3 = 7, 7, 7
    local end_v1, end_v2, end_v3
    for i = 0, bar_len - 1 do
        end_v1 = update_end(i == point_idx_v1, start_v1, #bar_char, #point_char)
        end_v2 = update_end(i == point_idx_v2, start_v2, #bar_char, #point_char)
        end_v3 = update_end(i == point_idx_v3, start_v3, #bar_char, #point_char)

        local hex_v1 =
            Color:hex_str(utils.round((i + 0.5) * max1 / bar_len), v2, v3, self.input_mode)
        local hex_v2 =
            Color:hex_str(v1, utils.round((i + 0.5) * max2 / bar_len), v3, self.input_mode)
        local hex_v3 =
            Color:hex_str(v1, v2, utils.round((i + 0.5) * max3 / bar_len), self.input_mode)
        set_hl(0, "CccV1" .. i, { fg = hex_v1 })
        set_hl(0, "CccV2" .. i, { fg = hex_v2 })
        set_hl(0, "CccV3" .. i, { fg = hex_v3 })
        add_hl(0, self.ns_id, "CccV1" .. i, 0, start_v1, end_v1)
        add_hl(0, self.ns_id, "CccV2" .. i, 1, start_v2, end_v2)
        add_hl(0, self.ns_id, "CccV3" .. i, 2, start_v3, end_v3)

        start_v1, start_v2, start_v3 = end_v1, end_v2, end_v3
    end
end

function UI:update()
    -- api.nvim_buf_clear_namespace(0, self.ns_id, 0, -1)
    utils.set_lines(0, 0, 4, self:buffer())
    self:highlight()
    local bg = self.color:hex_str()
    local fg = bg > "#800000" and "#000000" or "#ffffff"
    set_hl(0, "CccOutput", { fg = fg, bg = bg })
    local start = api.nvim_buf_get_lines(0, 3, 4, true)[1]:find("%S") - 1
    add_hl(0, self.ns_id, "CccOutput", 3, start, -1)
end

function UI:buffer()
    local buffer = {}
    local bar_len = config.get("bar_len")
    local output = self:output()
    if self.input_mode == "RGB" then
        local R, G, B = self.color:get_rgb()
        buffer = {
            table.concat({ "R:", ("%3d"):format(R), utils.create_bar(R, 255, bar_len) }, " "),
            table.concat({ "G:", ("%3d"):format(G), utils.create_bar(G, 255, bar_len) }, " "),
            table.concat({ "B:", ("%3d"):format(B), utils.create_bar(B, 255, bar_len) }, " "),
            string.rep(" ", self.win_width - #output) .. output,
        }
    elseif self.input_mode == "HSL" then
        local H, S, L = self.color:get_hsl()
        buffer = {
            table.concat({ "H:", ("%3d"):format(H), utils.create_bar(H, 360, bar_len) }, " "),
            table.concat({ "S:", ("%3d"):format(S), utils.create_bar(S, 100, bar_len) }, " "),
            table.concat({ "L:", ("%3d"):format(L), utils.create_bar(L, 100, bar_len) }, " "),
            string.rep(" ", self.win_width - #output) .. output,
        }
    end
    return buffer
end

function UI:output()
    return self.color:output(self.output_mode)
end

---@param int integer
---@param min integer
---@param max integer
---@return integer
local function fix_overflow(int, min, max)
    if int < min then
        return min
    elseif int > max then
        return max
    end
    return int
end

---@param delta integer
function UI:delta(delta)
    local lnum = utils.row()
    if self.input_mode == "RGB" then
        local R, G, B = self.color:get_rgb()
        if lnum == 1 then
            R = fix_overflow(R + delta, 0, 255)
        elseif lnum == 2 then
            G = fix_overflow(G + delta, 0, 255)
        elseif lnum == 3 then
            B = fix_overflow(B + delta, 0, 255)
        end
        self.color:set_rgb(R, G, B)
    else
        local H, S, L = self.color:get_hsl()
        if lnum == 1 then
            H = fix_overflow(H + delta, 0, 360)
        elseif lnum == 2 then
            S = fix_overflow(S + delta, 0, 100)
        elseif lnum == 3 then
            L = fix_overflow(L + delta, 0, 100)
        end
        self.color:set_hsl(H, S, L)
    end
    self:update()
end

function UI:set_percent(percent)
    local lnum = utils.row()
    if self.input_mode == "RGB" then
        local R, G, B = self.color:get_rgb()
        if lnum == 1 then
            R = utils.round(255 * percent / 100)
        elseif lnum == 2 then
            G = utils.round(255 * percent / 100)
        elseif lnum == 3 then
            B = utils.round(255 * percent / 100)
        end
        self.color:set_rgb(R, G, B)
    else
        local H, S, L = self.color:get_hsl()
        if lnum == 1 then
            H = utils.round(360 * percent / 100)
        elseif lnum == 2 then
            S = percent
        elseif lnum == 3 then
            L = percent
        end
        self.color:set_hsl(H, S, L)
    end
    self:update()
end

function UI:pick()
    ---@type string
    local current_line = api.nvim_get_current_line()
    local recognized, v1, v2, v3, start, end_ = utils.parse_color(current_line)
    local cursor_col = utils.col()
    if recognized and start <= cursor_col and cursor_col <= end_ then
        ---@cast v1 integer
        self.start_col = start
        self.end_col = end_
        self.color:set(self.input_mode, recognized, v1, v2, v3)
    end
end

function UI:toggle_input_mode()
    if self.input_mode == "RGB" then
        self.input_mode = "HSL"
        self.color:rgb2hsl()
    else
        self.input_mode = "RGB"
        self.color:hsl2rgb()
    end
    self:update()
end

function UI:toggle_output_mode()
    if self.output_mode == "RGB" then
        self.output_mode = "HSL"
    elseif self.output_mode == "HSL" then
        self.output_mode = "HEX"
    else
        self.output_mode = "RGB"
    end
    self:update()
end

return UI
