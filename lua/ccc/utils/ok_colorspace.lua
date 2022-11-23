--[[
Copyright (c) 2021 Björn Ottosson

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]
--

---@alias srgb number[]
---@alias linear number[]
---@alias lab number[]
---@alias hsv number[]
---@alias hsl number[]
---@alias lc number[]
---@alias st number[]
---@alias Cs number[]

local sqrt = math.sqrt
local atan2 = math.atan2
local pi = math.pi
local cos = math.cos
local sin = math.sin

---@param x number
---@return number
local function cbrt(x)
  return x ^ (1 / 3)
end

local unpack = unpack or table.unpack

---@param ... number
---@return number
local function max(...)
  local m = select(1, ...)
  for i = 2, select("#", ...) do
    local v = select(i, ...)
    if m < v then
      m = v
    end
  end
  return m
end

---@param ... number
---@return number
local function min(...)
  local m = select(1, ...)
  for i = 2, select("#", ...) do
    local v = select(i, ...)
    if m > v then
      m = v
    end
  end
  return m
end

---@param x number
---@return number
local function toe(x)
  local k1 = 0.206
  local k2 = 0.03
  local k3 = (1 + k1) / (1 + k2)

  return 0.5 * (k3 * x - k1 + sqrt((k3 * x - k1) ^ 2 + 4 * k2 * k3 * x))
end

---@param x number
---@return number
local function toe_inv(x)
  local k1 = 0.206
  local k2 = 0.03
  local k3 = (1 + k1) / (1 + k2)

  return (x ^ 2 + k1 * x) / (k3 * (x + k2))
end

local M = {}

---@param x number
---@return number
local function _srgb_to_linear(x)
  if x <= 0.04045 then
    return x / 12.92
  end
  return ((x + 0.055) / 1.055) ^ 2.4
end

---@param rgb srgb
---@return linear
function M.srgb_to_linear(rgb)
  local r, g, b = unpack(rgb)
  return { _srgb_to_linear(r), _srgb_to_linear(g), _srgb_to_linear(b) }
end

---@param x number
---@return number
local function _linear_to_srgb(x)
  if x <= 0.0031308 then
    return 12.92 * x
  else
    return 1.055 * x ^ (1 / 2.4) - 0.055
  end
end

---@param linear linear
---@return srgb
function M.linear_to_srgb(linear)
  local r, g, b = unpack(linear)
  return { _linear_to_srgb(r), _linear_to_srgb(g), _linear_to_srgb(b) }
end

---@param linear linear
---@return lab
function M.linear_to_oklab(linear)
  local r, g, b = unpack(linear)

  local l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
  local m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
  local s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b

  local l_ = cbrt(l)
  local m_ = cbrt(m)
  local s_ = cbrt(s)

  return {
    0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_,
    1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_,
    0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_,
  }
end

---@param lab lab
---@return srgb
function M.oklab_to_linear(lab)
  local L, a, b = unpack(lab)

  local l_ = L + 0.3963377774 * a + 0.2158037573 * b
  local m_ = L - 0.1055613458 * a - 0.0638541728 * b
  local s_ = L - 0.0894841775 * a - 1.2914855480 * b

  local l = l_ ^ 3
  local m = m_ ^ 3
  local s = s_ ^ 3

  return {
    4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
    -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
    -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s,
  }
end

---@param rgb srgb
---@return lab
function M.srgb_to_oklab(rgb)
  return M.linear_to_oklab(M.srgb_to_linear(rgb))
end

---@param lab lab
---@return srgb
function M.oklab_to_srgb(lab)
  return M.linear_to_srgb(M.oklab_to_linear(lab))
end

---Finds the maximum saturation possible for a given hue that fits in sRGB
---Saturation here is defined as S = C/L
---a and b must be normalized so a^2 + b^2 == 1
---@param a number
---@param b number
local function compute_max_saturation(a, b)
  -- Max saturation will be when one of r, g or b goes below zero.

  -- Select different coefficients depending on which component goes below zero first
  local k0, k1, k2, k3, k4, wl, wm, ws

  if -1.88170328 * a - 0.80936493 * b > 1 then
    -- Red component
    k0 = 1.19086277
    k1 = 1.76576728
    k2 = 0.59662641
    k3 = 0.75515197
    k4 = 0.56771245
    wl = 4.0767416621
    wm = -3.3077115913
    ws = 0.2309699292
  elseif 1.81444104 * a - 1.19445276 * b > 1 then
    -- Green component
    k0 = 0.73956515
    k1 = -0.45954404
    k2 = 0.08285427
    k3 = 0.12541070
    k4 = 0.14503204

    wl = -1.2684380046
    wm = 2.6097574011
    ws = -0.3413193965
  else
    -- Blue component
    k0 = 1.35733652
    k1 = -0.00915799
    k2 = -1.15130210
    k3 = -0.50559606
    k4 = 0.00692167

    wl = -0.0041960863
    wm = -0.7034186147
    ws = 1.7076147010
  end

  -- Approximate max saturation using a polynomial:
  local S = k0 + k1 * a + k2 * b + k3 * a * a + k4 * a * b

  -- Do one step Halley's method to get closer
  -- this gives an error less than 10e6, except for some blue hues where the dS/dh is close to infinite
  -- this should be sufficient for most applications, otherwise do two/three steps

  local k_l = 0.3963377774 * a + 0.2158037573 * b
  local k_m = -0.1055613458 * a - 0.0638541728 * b
  local k_s = -0.0894841775 * a - 1.2914855480 * b

  local l_ = 1 + S * k_l
  local m_ = 1 + S * k_m
  local s_ = 1 + S * k_s

  local l = l_ * l_ * l_
  local m = m_ * m_ * m_
  local s = s_ * s_ * s_

  local l_dS = 3 * k_l * l_ * l_
  local m_dS = 3 * k_m * m_ * m_
  local s_dS = 3 * k_s * s_ * s_

  local l_dS2 = 6 * k_l * k_l * l_
  local m_dS2 = 6 * k_m * k_m * m_
  local s_dS2 = 6 * k_s * k_s * s_

  local f = wl * l + wm * m + ws * s
  local f1 = wl * l_dS + wm * m_dS + ws * s_dS
  local f2 = wl * l_dS2 + wm * m_dS2 + ws * s_dS2

  S = S - f * f1 / (f1 * f1 - 0.5 * f * f2)

  return S
end

---@param a number
---@param b number
---@return lc
local function find_cusp(a, b)
  -- First, find the maximum saturation (saturation S = C/L)
  local S_cusp = compute_max_saturation(a, b)

  -- Convert to linear sRGB to find the first point where at least one of r,g or b >= 1:
  local rgb_at_max = M.oklab_to_linear({ 1, S_cusp * a, S_cusp * b })
  local L_cusp = cbrt(1 / max(rgb_at_max[1], rgb_at_max[2], rgb_at_max[3]))
  local C_cusp = L_cusp * S_cusp

  return { L_cusp, C_cusp }
end

---Finds intersection of the line defined by
---L = L0 * (1 - t) + t * L1;
---C = t * C1;
---a and b must be normalized so a^2 + b^2 == 1
---comment
---@param a number
---@param b number
---@param L1 number
---@param C1 number
---@param L0 number
---@param cusp? lc
---@return number
local function find_gamut_intersection(a, b, L1, C1, L0, cusp)
  if cusp == nil then
    -- Find the cusp of the gamut triangle
    cusp = find_cusp(a, b)
  end

  -- Find the intersection for upper and lower half seprately
  local t
  if ((L1 - L0) * cusp[2] - (cusp[1] - L0) * C1) <= 0 then
    -- Lower half
    t = cusp[2] * L0 / (C1 * cusp[1] + cusp[2] * (L0 - L1))
  else
    -- Upper half

    -- First intersect with triangle
    t = cusp[2] * (L0 - 1) / (C1 * (cusp[1] - 1) + cusp[2] * (L0 - L1))

    -- Then one step Halley's method
    local dL = L1 - L0
    local dC = C1

    local k_l = 0.3963377774 * a + 0.2158037573 * b
    local k_m = -0.1055613458 * a - 0.0638541728 * b
    local k_s = -0.0894841775 * a - 1.2914855480 * b

    local l_dt = dL + dC * k_l
    local m_dt = dL + dC * k_m
    local s_dt = dL + dC * k_s

    -- If higher accuracy is required, 2 or 3 iterations of the following block can be used:
    local L = L0 * (1 - t) + t * L1
    local C = t * C1

    local l_ = L + C * k_l
    local m_ = L + C * k_m
    local s_ = L + C * k_s

    local l = l_ * l_ * l_
    local m = m_ * m_ * m_
    local s = s_ * s_ * s_

    local ldt = 3 * l_dt * l_ * l_
    local mdt = 3 * m_dt * m_ * m_
    local sdt = 3 * s_dt * s_ * s_

    local ldt2 = 6 * l_dt * l_dt * l_
    local mdt2 = 6 * m_dt * m_dt * m_
    local sdt2 = 6 * s_dt * s_dt * s_

    local r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s - 1
    local r1 = 4.0767416621 * ldt - 3.3077115913 * mdt + 0.2309699292 * sdt
    local r2 = 4.0767416621 * ldt2 - 3.3077115913 * mdt2 + 0.2309699292 * sdt2

    local u_r = r1 / (r1 * r1 - 0.5 * r * r2)
    local t_r = -r * u_r

    local g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s - 1
    local g1 = -1.2684380046 * ldt + 2.6097574011 * mdt - 0.3413193965 * sdt
    local g2 = -1.2684380046 * ldt2 + 2.6097574011 * mdt2 - 0.3413193965 * sdt2

    local u_g = g1 / (g1 * g1 - 0.5 * g * g2)
    local t_g = -g * u_g

    local b_ = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s - 1
    local b1 = -0.0041960863 * ldt - 0.7034186147 * mdt + 1.7076147010 * sdt
    local b2 = -0.0041960863 * ldt2 - 0.7034186147 * mdt2 + 1.7076147010 * sdt2

    local u_b = b1 / (b1 * b1 - 0.5 * b_ * b2)
    local t_b = -b_ * u_b

    t_r = u_r >= 0 and t_r or 10e5
    t_g = u_g >= 0 and t_g or 10e5
    t_b = u_b >= 0 and t_b or 10e5

    t = t + min(t_r, t_g, t_b)
  end
  return t
end

---@param a_ number
---@param b_ number
---@param cusp? lc
---@return st
local function get_ST_max(a_, b_, cusp)
  if cusp == nil then
    cusp = find_cusp(a_, b_)
  end

  local l, c = unpack(cusp)
  return { c / l, c / (1 - l) }
end

---@param L number
---@param a_ number
---@param b_ number
---@return Cs
local function get_Cs(L, a_, b_)
  local cusp = find_cusp(a_, b_)

  local C_max = find_gamut_intersection(a_, b_, L, 1, L, cusp)
  local ST_max = get_ST_max(a_, b_, cusp)

    -- stylua: ignore
    local S_mid = 0.11516993 + 1 / (
        7.44778970 + 4.15901240 * b_
        + a_ * (-2.19557347 +  1.75198401 * b_
        + a_ * (-2.13704948 - 10.02301043 * b_
        + a_ * (-4.24894561 +  5.38770819 * b_ + 4.69891013 * a_
        )))
    )

    -- stylua: ignore
    local T_mid = 0.11239642 + 1 / (
        1.61320320 - 0.68124379 * b_
        + a_ * ( 0.40370612 + 0.90148123 * b_
        + a_ * (-0.27087943 + 0.61223990 * b_
        + a_ * ( 0.00299215 - 0.45399568 * b_ - 0.14661872 * a_
        )))
    )

  local k = C_max / min((L * ST_max[1]), (1 - L) * ST_max[2])

  local C_mid
  do
    local C_a = L * S_mid
    local C_b = (1 - L) * T_mid

    C_mid = 0.9 * k * sqrt(sqrt(1 / (1 / (C_a ^ 4) + 1 / (C_b ^ 4))))
  end

  local C_0
  do
    local C_a = L * 0.4
    local C_b = (1 - L) * 0.8

    C_0 = sqrt(1 / (1 / (C_a ^ 2) + 1 / (C_b ^ 2)))
  end

  return { C_0, C_mid, C_max }
end

---@param rgb srgb
---@return hsv
function M.srgb_to_okhsv(rgb)
  local lab = M.srgb_to_oklab(rgb)

  local C = sqrt(lab[2] ^ 2 + lab[3] ^ 2)
  local a_ = lab[2] / C
  local b_ = lab[3] / C

  local L = lab[1]
  local h = 0.5 + 0.5 * atan2(-lab[3], -lab[2]) / pi

  local ST_max = get_ST_max(a_, b_)
  local S_max = ST_max[1]
  local S_0 = 0.5
  local T = ST_max[2]
  local k = 1 - S_0 / S_max

  local t = T / (C + L * T)
  local L_v = t * L
  local C_v = t * C

  local L_vt = toe_inv(L_v)
  local C_vt = C_v * L_vt / L_v

  local rgb_scale = M.oklab_to_linear({ L_vt, a_ * C_vt, b_ * C_vt })
  local scale_L = cbrt(1 / (max(rgb_scale[1], rgb_scale[2], rgb_scale[3], 0)))

  L = L / scale_L
  L = toe(L)

  local v = L / L_v
  local s = (S_0 + T) * C_v / ((T * S_0) + T * k * C_v)

  return { h, s, v }
end

---@param hsv hsv
---@return srgb
function M.okhsv_to_srgb(hsv)
  local h, s, v = unpack(hsv)
  local a_ = cos(2 * pi * h)
  local b_ = sin(2 * pi * h)

  local ST_max = get_ST_max(a_, b_)
  local S_max = ST_max[1]
  local S_0 = 0.5
  local T = ST_max[2]
  local k = 1 - S_0 / S_max

  local L_v = 1 - s * S_0 / (S_0 + T - T * k * s)
  local C_v = s * T * S_0 / (S_0 + T - T * k * s)

  local L = v * L_v
  local C = v * C_v

  local L_vt = toe_inv(L_v)
  local C_vt = C_v * L_vt / L_v

  local L_new = toe_inv(L) -- * L_v/L_vt;
  C = C * L_new / L
  L = L_new

  local rgb_scale = M.oklab_to_linear({ L_vt, a_ * C_vt, b_ * C_vt })
  local scale_L = cbrt(1 / (max(rgb_scale[1], rgb_scale[2], rgb_scale[3], 0)))

  -- remove to see effect without rescaling
  L = L * scale_L
  C = C * scale_L

  local rgb = M.oklab_to_srgb({ L, C * a_, C * b_ })
  return rgb
end

---@param rgb srgb
---@return hsl
function M.srgb_to_okhsl(rgb)
  local lab = M.srgb_to_oklab(rgb)

  local C = sqrt(lab[2] ^ 2 + lab[3] ^ 2)
  local a_ = lab[2] / C
  local b_ = lab[3] / C

  local L = lab[1]
  local h = 0.5 + 0.5 * atan2(-lab[3], -lab[2]) / pi

  local Cs = get_Cs(L, a_, b_)
  local C_0 = Cs[1]
  local C_mid = Cs[2]
  local C_max = Cs[3]

  local s
  if C < C_mid then
    local k_0 = 0
    local k_1 = 0.8 * C_0
    local k_2 = (1 - k_1 / C_mid)

    local t = (C - k_0) / (k_1 + k_2 * (C - k_0))
    s = t * 0.8
  else
    local k_0 = C_mid
    local k_1 = 0.2 * C_mid ^ 2 * 1.25 ^ 2 / C_0
    local k_2 = (1 - k_1 / (C_max - C_mid))

    local t = (C - k_0) / (k_1 + k_2 * (C - k_0))
    s = 0.8 + 0.2 * t
  end

  local l = toe(L)
  return { h, s, l }
end

---@param hsl hsl
---@return srgb
function M.okhsl_to_srgb(hsl)
  local h, s, l = unpack(hsl)
  if l == 1 then
    return { 1, 1, 1 }
  elseif l == 0 then
    return { 0, 0, 0 }
  end

  local a_ = cos(2 * pi * h)
  local b_ = sin(2 * pi * h)
  local L = toe_inv(l)

  local Cs = get_Cs(L, a_, b_)
  local C_0 = Cs[1]
  local C_mid = Cs[2]
  local C_max = Cs[3]

  local C, t, k_0, k_1, k_2
  if s < 0.8 then
    t = 1.25 * s
    k_0 = 0
    k_1 = 0.8 * C_0
    k_2 = (1 - k_1 / C_mid)
  else
    t = 5 * (s - 0.8)
    k_0 = C_mid
    k_1 = 0.2 * C_mid ^ 2 * 1.25 ^ 2 / C_0
    k_2 = (1 - k_1 / (C_max - C_mid))
  end

  C = k_0 + t * k_1 / (1 - k_2 * t)

  local rgb = M.oklab_to_srgb({ L, C * a_, C * b_ })
  return rgb
end

return M
