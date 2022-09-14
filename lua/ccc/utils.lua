local utils = {}

function utils.feedkey(key)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "n", false)
end

---@param ... integer
---@return integer max value
---@return integer the index of max value
function utils.max(...)
    local m = select(1, ...)
    local idx = 1
    for i = 2, select("#", ...) do
        local x = select(i, ...)
        if m < x then
            m = x
            idx = i
        end
    end
    return m, idx
end

---@param ... integer
---@return integer min value
---@return integer the index of min value
function utils.min(...)
    local m = select(1, ...)
    local idx = 1
    for i = 2, select("#", ...) do
        local x = select(i, ...)
        if m > x then
            m = x
            idx = i
        end
    end
    return m, idx
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
    local MAX, i_max = utils.max(R, G, B)
    local MIN, _ = utils.min(R, G, B)

    local round = utils.round
    if R == G and R == B then
        H = 0
        S = 0
    else
        if i_max == 1 then
            -- R is max
            H = round((G - B) / (MAX - MIN) * 60)
        elseif i_max == 2 then
            -- G is max
            H = round((B - R) / (MAX - MIN) * 60 + 120)
        else
            -- B is max
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

function utils.create_bar(value, max, bar_max)
    local ratio = utils.round(value / max * bar_max)
    return string.rep("ﱢ", ratio) .. string.rep(" ", bar_max - ratio)
end

return utils
