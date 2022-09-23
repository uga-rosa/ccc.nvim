local utils = require("ccc.utils")

---@class SafeArray
---@field private _raw unknown[]
---@field private _len integer
local SafeArray = {}
SafeArray.__index = SafeArray

---@param t any[]
---@return SafeArray
function SafeArray.new(t)
    vim.validate({ t = { t, "t" } })
    return setmetatable({
        _raw = t,
        _len = #t,
    }, SafeArray)
end

---@return unknown[]
function SafeArray:raw() return self._raw end

---@return ...unknown
function SafeArray:unpack() return unpack(self._raw) end

---@param func fun(x: unknown): unknown
---@return SafeArray
function SafeArray:map(func)
    vim.validate({ func = { func, "f" } })
    local new = {}
    for i = 1, self._len do
        new[i] = func(self._raw[i])
    end
    return SafeArray.new(new)
end

---@param func fun(x: unknown)
function SafeArray:apply(func)
    vim.validate({ func = { func, "f" } })
    for i = 1, self._len do
        func(self._raw[i])
    end
end

---@param sep? string
---@param i? integer
---@param j? integer
---@return string
function SafeArray:concat(sep, i, j)
    vim.validate({
        sep = { sep, "s", true },
        i = { i, "n", true },
        j = { j, "n", true },
    })
    sep = vim.F.if_nil(sep, "")
    i = vim.F.if_nil(i, 1)
    j = vim.F.if_nil(j, self._len)
    return table.concat(self._raw, sep, i, j)
end

---@return number
function SafeArray:max() return utils.max(unpack(self._raw)) end

---@return number
function SafeArray:min() return utils.min(unpack(self._raw)) end

---@return table<any, boolean>
function SafeArray:to_set()
    local new = {}
    for _, v in ipairs(self._raw) do
        new[v] = true
    end
    return new
end

return SafeArray
