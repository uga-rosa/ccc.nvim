local api = vim.api

local utils = {}

---@param key string
---@param plain? boolean
function utils.feedkey(key, plain)
    if not plain then
        key = api.nvim_replace_termcodes(key, true, false, true)
    end
    api.nvim_feedkeys(key, "n", false)
end

---(1,1)-index
---@return integer[]
function utils.cursor()
    local pos = api.nvim_win_get_cursor(0)
    pos[2] = pos[2] + 1
    return pos
end

---(1,1)-index
---@param pos integer[]
function utils.cursor_set(pos)
    pos[2] = pos[2] - 1
    api.nvim_win_set_cursor(0, pos)
end

---1-index
---@return integer
function utils.row()
    return utils.cursor()[1]
end

---1-index
---@return integer
function utils.col()
    return utils.cursor()[2]
end

---@param bufnr integer
---@param start integer
---@param end_ integer
---@param lines string[]
function utils.set_lines(bufnr, start, end_, lines)
    api.nvim_buf_set_option(bufnr, "modifiable", true)
    api.nvim_buf_set_lines(bufnr, start, end_, false, lines)
    api.nvim_buf_set_option(bufnr, "modifiable", false)
end

---@param ... number
---@return number max
function utils.max(...)
    local max = select(1, ...)
    for i = 2, select("#", ...) do
        local x = select(i, ...)
        if max < x then
            max = x
        end
    end
    return max
end

---@param ... number
---@return number min
function utils.min(...)
    local min = select(1, ...)
    for i = 2, select("#", ...) do
        local x = select(i, ...)
        if min < x then
            min = x
        end
    end
    return min
end

---@param float number
---@return integer
function utils.round(float)
    vim.validate({ float = { float, "n" } })
    return math.floor(float + 0.5)
end

---@param R integer
---@param G integer
---@param B integer
---@return integer H
---@return integer S
---@return integer L
function utils.rgb2hsl(R, G, B)
    vim.validate({
        R = { R, "n" },
        G = { G, "n" },
        B = { B, "n" },
    })

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
    vim.validate({
        H = { H, "n" },
        S = { S, "n" },
        L = { L, "n" },
    })

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

---@param array any[]
---@param value any
---@param func? function
---@return integer?
function utils.search_idx(array, value, func)
    vim.validate({
        array = { array, "t" },
        func = { func, "f", true },
    })
    func = vim.F.if_nil(func, function(x)
        return x
    end)

    for i, v in ipairs(array) do
        if func(v) == value then
            return i
        end
    end
end

return utils
