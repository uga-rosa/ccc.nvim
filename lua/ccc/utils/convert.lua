local utils = require("ccc.utils")
local convert = {}

---@param RGB integer[]
---@return integer[] HSL
function convert.rgb2hsl(RGB)
    local R, G, B = unpack(RGB)
    vim.validate({
        R = { R, "n" },
        G = { G, "n" },
        B = { B, "n" },
    })

    local H, S, L

    local MAX = utils.max(R, G, B)
    local MIN = utils.min(R, G, B)

    if R == G and R == B then
        H = 0
        S = 0
    else
        if MAX == R then
            H = (G - B) / (MAX - MIN) * 60
        elseif MAX == G then
            H = (B - R) / (MAX - MIN) * 60 + 120
        else
            H = (R - G) / (MAX - MIN) * 60 + 240
        end
        if H < 0 then
            H = H + 360
        end
    end

    L = (MAX + MIN) / 2 * 100 / 255

    if not S and L <= 50 then
        S = (MAX - MIN) / (MAX + MIN) * 100
    else
        S = (MAX - MIN) / (510 - (MAX + MIN)) * 100
    end

    return vim.tbl_map(utils.round, { H, S, L })
end

---@param HSL integer[]
---@return integer[] RGB
function convert.hsl2rgb(HSL)
    local H, S, L = unpack(HSL)
    vim.validate({
        H = { H, "n" },
        S = { S, "n" },
        L = { L, "n" },
    })

    local RGB

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
        RGB = { MAX, f(H), MIN }
    elseif H < 120 then
        RGB = { f(120 - H), MAX, MIN }
    elseif H < 180 then
        RGB = { MIN, MAX, f(H - 120) }
    elseif H < 240 then
        RGB = { MIN, f(240 - H), MAX }
    elseif H < 300 then
        RGB = { f(H - 240), MIN, MAX }
    else
        RGB = { MAX, MIN, f(360 - H) }
    end

    RGB = vim.tbl_map(utils.round, RGB)
    return RGB
end

return convert
