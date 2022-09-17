local utils = require("ccc.utils")
local hsluv = require("ccc.utils.hsluv")

local convert = {}

---@param RGB number[]
---@return number[] HSLuv
function convert.rgb2hsluv(RGB)
    RGB = vim.tbl_map(function (x)
        return x / 255
    end, RGB)
    return hsluv.rgb_to_hsluv(RGB)
end

---@param HSLuv number[]
---@return number[] RGB
function convert.hsluv2rgb(HSLuv)
    RGB = hsluv.hsluv_to_rgb(HSLuv)
    return vim.tbl_map(function (x)
        return x * 255
    end, RGB)
end

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

    return { H, S, L }
end

---@param HSL integer[]
---@return number[] RGB
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

    return RGB
end

---@param x number
---@return number
local function div255(x)
    return x / 255
end

---@param RGB number[]
---@return number[] CMYK
function convert.rgb2cmyk(RGB)
    local R_, G_, B_ = unpack(vim.tbl_map(div255, RGB))
    local K = 1 - utils.max(R_, G_, B_)
    if K == 1 then
        return { 0, 0, 0, 1 }
    end
    return {
        (1 - R_ - K) / (1 - K),
        (1 - G_ - K) / (1 - K),
        (1 - B_ - K) / (1 - K),
        K,
    }
end

---@param CMYK number[]
---@return number[] RGB
function convert.cmyk2rgb(CMYK)
    local C, M, Y, K = unpack(CMYK)
    if K == 1 then
        return { 0, 0, 0 }
    end
    return {
        255 * (1 - C) * (1 - K),
        255 * (1 - M) * (1 - K),
        255 * (1 - Y) * (1 - K),
    }
end

---@param RGB number[]
---@return number[] Linear
function convert.rgb2linear(RGB)
    return vim.tbl_map(function(x)
        x = x / 255
        if x <= 0.04045 then
            return x / 12.92
        end
        return ((x + 0.055) / 1.055) ^ 2.4
    end, RGB)
end

---@param Linear number[]
---@return number[]
function convert.linear2rgb(Linear)
    return vim.tbl_map(function(x)
        if x <= 0.0031308 then
            x = 12.92 * x
        else
            x = 1.055 * x ^ (1 / 2.4) - 0.055
        end
        return x * 255
    end, Linear)
end

---@alias matrix number[][]
---@alias vector number[]

---@param a vector
---@param b vector
---@return number
local function dot(a, b)
    assert(#a == #b)
    local result = 0
    for i = 1, #a do
        result = result + a[i] * b[i]
    end
    return result
end

---@param m matrix
---@param v vector
---@return vector
local function product(m, v)
    local row = #m
    local result = {}
    for i = 1, row do
        result[i] = dot(m[i], v)
    end
    return result
end

local linear2xyz = {
    { 0.41239079926595, 0.35758433938387, 0.18048078840183 },
    { 0.21263900587151, 0.71516867876775, 0.072192315360733 },
    { 0.019330818715591, 0.11919477979462, 0.95053215224966 },
}
local xyz2linear = {
    { 3.240969941904521, -1.537383177570093, -0.498610760293 },
    { -0.96924363628087, 1.87596750150772, 0.041555057407175 },
    { 0.055630079696993, -0.20397695888897, 1.056971514242878 },
}

---@param Linear number[]
---@return number[] XYZ
function convert.linear2xyz(Linear)
    return product(linear2xyz, Linear)
end

---@param XYZ number[]
---@return number[] Linear
function convert.xyz2linear(XYZ)
    return product(xyz2linear, XYZ)
end

---@param RGB number[]
---@return number[] XYZ
function convert.rgb2xyz(RGB)
    local Linear = convert.rgb2linear(RGB)
    return convert.linear2xyz(Linear)
end

---@param XYZ number[]
---@return number[] RGB
function convert.xyz2rgb(XYZ)
    local Linear = convert.xyz2linear(XYZ)
    local RGB = convert.linear2rgb(Linear)
    for _, v in ipairs(RGB) do
        if v < 0 or 255 < v then
            return { 0, 0, 0 }
        end
    end
    return RGB
end

---@param XYZ number[]
---@return number[] Lab
function convert.xyz2lab(XYZ)
    local X, Y, Z = unpack(XYZ)
    local Xn, Yn, Zn = 0.9505, 1, 1.089
    local function f(t)
        if t > (6 / 29) ^ 3 then
            return 116 * t ^ (1 / 3) - 16
        end
        return (29 / 3) ^ 3 * t
    end
    return {
        f(Y / Yn),
        (500 / 116) * (f(X / Xn) - f(Y / Yn)),
        (200 / 116) * (f(Y / Yn) - f(Z / Zn)),
    }
end

---@param Lab number[]
---@return number[] XYZ
function convert.lab2xyz(Lab)
    local L, a, b = unpack(Lab)
    local Xn, Yn, Zn = 0.9505, 1, 1.089
    local fy = (L + 16) / 116
    local fx = fy + (a / 500)
    local fz = fy - (b / 200)
    local function t(f)
        if f > 6 / 29 then
            return f ^ 3
        end
        return (116 * f - 16) * (3 / 29) ^ 3
    end
    return {
        t(fx) * Xn,
        t(fy) * Yn,
        t(fz) * Zn,
    }
end

---@param RGB number[]
---@return number[] Lab
function convert.rgb2lab(RGB)
    local Linear = convert.rgb2linear(RGB)
    local XYZ = convert.linear2xyz(Linear)
    return convert.xyz2lab(XYZ)
end

---@param Lab number[]
---@return number[] RGB
function convert.lab2rgb(Lab)
    local XYZ = convert.lab2xyz(Lab)
    local Linear = convert.xyz2linear(XYZ)
    local RGB = convert.linear2rgb(Linear)
    return vim.tbl_map(function(x)
        return utils.fix_overflow(x, 0, 255)
    end, RGB)
end

return convert
