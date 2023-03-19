local M = {}

---@param a number
---@param b number
---@param limit number
---@return boolean
function M.near(a, b, limit)
  return math.abs(a - b) < limit
end

return M
