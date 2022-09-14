local api = vim.api

local Color = require("ccc.color")
local config = require("ccc.config")
local utils = require("ccc.utils")

---@alias input_mode "RGB" | "HSL"
---@alias output_mode "RGB" | "HSL" | "ColorCode"

---@class UI
---@field color Color
---@field input_mode input_mode
---@field output_mode output_mode
---@field bufnr integer
---@field win_id integer
---@field ns_id integer
---@field row integer 1-index
---@field start_col integer 1-index
---@field end_col integer 1-index
---@field is_insert boolean
local UI = {}

local opts = {
    width = 17,
    height = 4,
}

function UI:init()
    self.input_mode = self.input_mode or config.get("default_input_mode")
    self.output_mode = self.output_mode or config.get("default_output_mode")
    self.color = Color.new(self.input_mode)
    self.ns_id = self.ns_id or api.nvim_create_namespace("ccc")
    local cursor_pos = api.nvim_win_get_cursor(0)
    self.row = cursor_pos[1]
    self.start_col = cursor_pos[2] + 1
    self.end_col = cursor_pos[2]
end

---@param insert boolean
function UI:open(insert)
    self:init()
    self.is_insert = insert
    if not insert then
        self:pick()
    end
    if self.bufnr == nil then
        self.bufnr = api.nvim_create_buf(false, true)
    end
    local win_opts = vim.tbl_extend("error", opts, config.get("win_opts"))
    for k, v in pairs(win_opts) do
        if type(v) == "function" then
            win_opts[k] = v()
        end
    end
    self.win_id = api.nvim_open_win(self.bufnr, true, win_opts)
    self:update()

    local mappings = config.get("mappings")
    for lhs, rhs in pairs(mappings) do
        vim.keymap.set("n", lhs, rhs, { nowait = true, buffer = self.bufnr })
    end
    if insert then
        utils.feedkey("<Esc>")
    end
    vim.opt_local.buftype = "nofile"
end

function UI:close()
    if self.win_id == nil then
        return
    end
    local mappings = config.get("mappings")
    for lhs, _ in pairs(mappings) do
        vim.keymap.del("n", lhs, { buffer = self.bufnr })
    end
    api.nvim_win_close(self.win_id, true)
    if self.is_insert then
        vim.cmd("startinsert")
    end
    api.nvim_win_set_cursor(0, { self.row, self.start_col - 1 })
end

function UI:quit()
    self:close()
end

function UI:complete()
    self:close()
    if self.is_insert then
        self:insert()
    else
        self:replace()
    end
end

function UI:insert()
    vim.api.nvim_feedkeys(self:output(), "n", false)
end

function UI:replace()
    local line = api.nvim_get_current_line()
    local new_line = line:sub(1, self.start_col - 1) .. self:output() .. line:sub(self.end_col + 1)
    api.nvim_set_current_line(new_line)
end

function UI:highlight_rgb()
    for i = 0, 9 do
        local start = i * 4 + 7
        local end_ = start + 4
        api.nvim_buf_add_highlight(0, self.ns_id, "CccRed" .. i, 0, start, end_)
        api.nvim_buf_add_highlight(0, self.ns_id, "CccBlue" .. i, 1, start, end_)
        api.nvim_buf_add_highlight(0, self.ns_id, "CccGreen" .. i, 2, start, end_)
    end
end

function UI:update()
    api.nvim_buf_clear_namespace(0, self.ns_id, 0, -1)
    api.nvim_buf_set_lines(self.bufnr, 0, 4, false, self:buffer())
    if self.input_mode == "RGB" then
        self:highlight_rgb()
    end
    local bg = self.color:colorcode()
    local fg = bg > "#800000" and "#000000" or "#ffffff"
    api.nvim_set_hl(0, "CccOutput", { fg = fg, bg = bg })
    local start = api.nvim_buf_get_lines(0, 3, 4, true)[1]:find("%S") - 1
    api.nvim_buf_add_highlight(0, self.ns_id, "CccOutput", 3, start, -1)
end

function UI:buffer()
    local buffer = {}
    local width = 2 + 1 + 3 + 1 + 10
    if self.input_mode == "RGB" then
        local R, G, B = self.color:get_rgb()
        buffer = {
            table.concat({ "R:", ("%3d"):format(R), utils.create_bar(R, 255, 10) }, " "),
            table.concat({ "G:", ("%3d"):format(G), utils.create_bar(G, 255, 10) }, " "),
            table.concat({ "B:", ("%3d"):format(B), utils.create_bar(B, 255, 10) }, " "),
            ("%" .. width .. "s"):format(self:output()),
        }
    elseif self.input_mode == "HSL" then
        local H, S, L = self.color:get_hsl()
        buffer = {
            table.concat({ "H:", ("%3d"):format(H), utils.create_bar(H, 255, 10) }, " "),
            table.concat({ "S:", ("%3d"):format(S), utils.create_bar(S, 100, 10) }, " "),
            table.concat({ "L:", ("%3d"):format(L), utils.create_bar(L, 100, 10) }, " "),
            ("%" .. width .. "s"):format(self:output()),
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
    local lnum = api.nvim_win_get_cursor(0)[1]
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
            H = fix_overflow(H + delta, 0, 255)
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
    local lnum = api.nvim_win_get_cursor(0)[1]
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
            H = utils.round(255 * percent / 100)
        elseif lnum == 2 then
            S = percent
        elseif lnum == 3 then
            L = percent
        end
        self.color:set_hsl(H, S, L)
    end
    self:update()
end

local colorcode_pattern =
    "#([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])"
local rgb_pattern = "rgb%((%d+),%s*(%d+),%s*(%d+)%)"
local hsl_pattern = "hsl%((%d+),%s*(%d+)%%,%s*(%d+)%%%)"

---@param hex string
---@return integer
local function hex2num(hex)
    return tonumber(hex, 16)
end

function UI:pick()
    ---@type string
    local current_line = api.nvim_get_current_line()
    local cursor_col = api.nvim_win_get_cursor(0)[2] + 1
    local s, e, cap1, cap2, cap3 = current_line:find(colorcode_pattern)
    if s and s <= cursor_col and cursor_col <= e then
        self.start_col = s
        self.end_col = e
        self.color:set_rgb(hex2num(cap1), hex2num(cap2), hex2num(cap3))
    end
    s, e, cap1, cap2, cap3 = current_line:find(rgb_pattern)
    if s and s <= cursor_col and cursor_col <= e then
        self.start_col = s
        self.end_col = e
        cap1, cap2, cap3 = tonumber(cap1), tonumber(cap2), tonumber(cap3)
        ---@diagnostic disable-next-line
        self.color:set_rgb(cap1, cap2, cap3)
    end
    s, e, cap1, cap2, cap3 = current_line:find(hsl_pattern)
    if s and s <= cursor_col and cursor_col <= e then
        self.start_col = s
        self.end_col = e
        cap1, cap2, cap3 = tonumber(cap1), tonumber(cap2), tonumber(cap3)
        ---@diagnostic disable-next-line
        self.color:set_hsl(cap1, cap2, cap3)
    end
end

function UI:input_mode_toggle()
    if self.input_mode == "RGB" then
        self.input_mode = "HSL"
        self.color:rgb2hsl()
    else
        self.input_mode = "RGB"
        self.color:rgb2hsl()
    end
    self:update()
end

function UI:output_mode_toggle()
    if self.output_mode == "RGB" then
        self.output_mode = "HSL"
    elseif self.output_mode == "HSL" then
        self.output_mode = "ColorCode"
    else
        self.output_mode = "RGB"
    end
    self:update()
end

return UI
