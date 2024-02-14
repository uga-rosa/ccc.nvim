---@param rgb integer[]
---@return RGB
local function to_0_1(rgb)
  return { rgb[1] / 255, rgb[2] / 255, rgb[3] / 255 }
end

---@param rgb RGB
---@return integer[]
local function to_0_255(rgb)
  return {
    math.floor(rgb[1] * 255),
    math.floor(rgb[2] * 255),
    math.floor(rgb[3] * 255),
  }
end

local M = {}

---@param str string
---@return RGB RGB
function M.parse(str)
  local r_s, g_s, b_s = str:match("^#(%x%x)(%x%x)(%x%x)$")
  local r, g, b = tonumber(r_s, 16), tonumber(g_s, 16), tonumber(b_s, 16)
  if r and g and b then
    return to_0_1({ r, g, b })
  else
    error(str .. " is not a color in hex format")
  end
end

---@param rgb RGB
---@return string
function M.stringify(rgb)
  rgb = to_0_255(rgb)
  return ("#%02x%02x%02x"):format(rgb[1], rgb[2], rgb[3])
end

return M
