---@class safe_array
---@field raw unknown[]
---@field len integer
local safe_array = {}
safe_array.__index = safe_array

---@param t any[]
---@return safe_array
function safe_array.new(t)
    vim.validate({ t = { t, "t" } })
    return setmetatable({
        raw = t,
        len = #t,
    }, safe_array)
end

---@return unknown[]
function safe_array:unpack()
    return self.raw
end

---@param func fun(x: any): any
---@return safe_array
function safe_array:map(func)
    vim.validate({ func = { func, "f" } })
    local new = {}
    for i, v in ipairs(self.raw) do
        new[i] = func(v)
    end
    return safe_array.new(new)
end

---@param func fun(x: any)
function safe_array:apply(func)
    vim.validate({ func = { func, "f" } })
    for _, v in ipairs(self.raw) do
        func(v)
    end
end

---@param sep? string
---@param i? integer
---@param j? integer
---@return string
function safe_array:concat(sep, i, j)
    vim.validate({
        sep = { sep, "s", true },
        i = { i, "n", true },
        j = { j, "n", true },
    })
    sep = vim.F.if_nil(sep, "")
    i = vim.F.if_nil(i, 1)
    j = vim.F.if_nil(j, #self.raw)
    return table.concat(self.raw, sep, i, j)
end

---@class Set table<any, boolean>

---@return Set
function safe_array:to_set()
    local new = {}
    for _, v in ipairs(self.raw) do
        new[v] = true
    end
    return new
end

return safe_array
