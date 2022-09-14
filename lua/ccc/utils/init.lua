local api = vim.api

local config = require("ccc.config")

local utils = {}

---@param key string
---@param plain? boolean
function utils.feedkey(key, plain)
    if not plain then
        key = api.nvim_replace_termcodes(key, true, false, true)
    end
    api.nvim_feedkeys(key, "n", false)
end

---@return integer
function utils.cursor()
    return api.nvim_win_get_cursor(0)
end

---@return integer
function utils.row()
    return api.nvim_win_get_cursor(0)[1]
end

---@return integer
function utils.col()
    return api.nvim_win_get_cursor(0)[2] + 1
end

---@param bufnr integer
---@param start integer
---@param end_ integer
---@param lines string[]
function utils.set_lines(bufnr, start, end_, lines)
    vim.opt_local.modifiable = true
    api.nvim_buf_set_lines(bufnr, start, end_, false, lines)
    vim.opt_local.modifiable = false
end

---@param ... integer
---@return integer max value
function utils.max(...)
    local m = select(1, ...)
    for i = 2, select("#", ...) do
        local x = select(i, ...)
        if m < x then
            m = x
        end
    end
    return m
end

---@param ... integer
---@return integer min value
function utils.min(...)
    local m = select(1, ...)
    for i = 2, select("#", ...) do
        local x = select(i, ...)
        if m > x then
            m = x
        end
    end
    return m
end

---@param float number
---@return integer
function utils.round(float)
    return math.floor(float + 0.5)
end

---@param R integer
---@param G integer
---@param B integer
---@return integer H
---@return integer S
---@return integer L
function utils.rgb2hsl(R, G, B)
    ---@type integer, integer, integer
    local H, S, L
    local MAX = utils.max(R, G, B)
    local MIN = utils.min(R, G, B)

    local round = utils.round
    if R == G and R == B then
        H = 0
        S = 0
    else
        if MAX == R then
            H = round((G - B) / (MAX - MIN) * 60)
        elseif MAX == G then
            H = round((B - R) / (MAX - MIN) * 60 + 120)
        else
            H = round((R - G) / (MAX - MIN) * 60 + 240)
        end
        if H < 0 then
            H = H + 360
        end
    end

    L = round((MAX + MIN) / 2 * 100 / 255)

    if L <= 50 then
        S = S or round((MAX - MIN) / (MAX + MIN) * 100)
    else
        S = S or round((MAX - MIN) / (510 - (MAX + MIN)) * 100)
    end

    return H, S, L
end

---@param H integer
---@param S integer
---@param L integer
---@return integer R
---@return integer G
---@return integer B
function utils.hsl2rgb(H, S, L)
    local R, G, B
    if H == 360 then
        H = 0
    end

    local L_ = L
    if L >= 50 then
        L_ = 100 - L
    end

    local MAX = 2.55 * (L + L_ * S / 100)
    local MIN = 2.55 * (L - L_ * S / 100)

    local function f(x)
        return x / 60 * (MAX - MIN) + MIN
    end

    if H < 60 then
        R, G, B = MAX, f(H), MIN
    elseif H < 120 then
        R, G, B = f(120 - H), MAX, MIN
    elseif H < 180 then
        R, G, B = MIN, MAX, f(H - 120)
    elseif H < 240 then
        R, G, B = MIN, f(240 - H), MAX
    elseif H < 300 then
        R, G, B = f(H - 240), MIN, MAX
    else
        R, G, B = MAX, MIN, f(360 - H)
    end

    return utils.round(R), utils.round(G), utils.round(B)
end

function utils.ratio(value, max, bar_len)
    return utils.round(value / max * bar_len)
end

function utils.create_bar(value, max, bar_len)
    local ratio = utils.ratio(value, max, bar_len)
    local bar_char = config.get("bar_char")
    local point_char = config.get("point_char")
    if ratio == 0 then
        return point_char .. string.rep(bar_char, bar_len - 1)
    end
    return string.rep(bar_char, ratio - 1) .. point_char .. string.rep(bar_char, bar_len - ratio)
end

local hex_pattern = "#" .. string.rep("([0-9a-fA-F][0-9a-fA-F])", 3)
local rgb_pattern = "rgb%((%d+),%s*(%d+),%s*(%d+)%)"
local hsl_pattern = "hsl%((%d+),%s*(%d+)%%,%s*(%d+)%%%)"

---@param s string
---@return input_mode recognized
---@return integer R or H
---@return integer G or S
---@return integer B or L
---@return integer start
---@return integer end_
---@overload fun(s: string): fail: nil, err_msg: string
function utils.parse_color(s)
    local start, end_, cap1, cap2, cap3 = s:find(hex_pattern)
    if start then
        local R, G, B = tonumber(cap1, 16), tonumber(cap2, 16), tonumber(cap3, 16)
        return "RGB", R, G, B, start, end_
    end
    start, end_, cap1, cap2, cap3 = s:find(rgb_pattern)
    if start then
        local R, G, B = tonumber(cap1, 10), tonumber(cap2, 10), tonumber(cap3, 10)
        return "RGB", R, G, B, start, end_
    end
    start, end_, cap1, cap2, cap3 = s:find(hsl_pattern)
    if start then
        local H, S, L = tonumber(cap1, 10), tonumber(cap2, 10), tonumber(cap3, 10)
        return "HSL", H, S, L, start, end_
    end
    ---@diagnostic disable-next-line
    return nil, "Unable to recognize color patterns"
end

return utils
