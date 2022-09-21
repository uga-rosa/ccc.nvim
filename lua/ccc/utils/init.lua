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

---@param msg string
---@param ... unknown
function utils.notify(msg, ...)
    if select("#", ...) > 0 then
        msg = msg:format(...)
    end
    vim.notify(msg)
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
        if min > x then
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

---@param int integer
---@param min integer
---@param max integer
---@return integer
function utils.fix_overflow(int, min, max)
    if int < min then
        return min
    elseif int > max then
        return max
    end
    return int
end

---@param HEX string
---@return boolean
local function is_bright(HEX)
    -- 0-255
    local R = tonumber(HEX:sub(2, 3), 16)
    local G = tonumber(HEX:sub(4, 5), 16)
    local B = tonumber(HEX:sub(6, 7), 16)
    local luminance = 0.298912 * R + 0.586611 * G + 0.114478 * B
    return luminance > 127
end

---@param bg_hex string
---@return string
function utils.fg_hex(bg_hex)
    if is_bright(bg_hex) then
        return "#000000"
    else
        return "#ffffff"
    end
end

---@param exclude_pattern nil | string | string[]
---@param pattern string[]
---@return string[]
function utils.expand_template(exclude_pattern, pattern)
    if exclude_pattern == nil then
        exclude_pattern = {}
    elseif type(exclude_pattern) == "string" then
        exclude_pattern = { exclude_pattern }
    end
    local new = {}
    for _, ex in pairs(exclude_pattern) do
        if ex:find("{{pattern}}", 1, true) then
            for _, pat in pairs(pattern) do
                pat = pat:gsub("%%", "%%%%")
                local expanded = ex:gsub("{{pattern}}", pat)
                table.insert(new, expanded)
            end
        else
            table.insert(new, ex)
        end
    end
    return new
end

---@param exclude_pattern nil | string | string[]
---@param s any
---@param start any
---@param end_ any
---@return boolean
function utils.is_excluded(exclude_pattern, pattern, s, init, start, end_)
    exclude_pattern = utils.expand_template(exclude_pattern, pattern)
    dump(exclude_pattern)
    for _, ex in pairs(exclude_pattern) do
        local ex_start, ex_end = s:find(ex, init)
        if ex_start and ex_start <= start and end_ <= ex_end then
            return true
        end
    end
    return false
end

return utils
