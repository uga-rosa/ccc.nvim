-- uga-rosa/estrela.lua
-- array module

local load = loadstring or load

---@alias callbackFn fun(x: unknown, i: integer, self: estrela.array): unknown

local callback_template = [[
return function(x, i, self)
  return %s
end
]]

---@alias mapFn fun(x: unknown, i: integer): unknown

local mapFn_template = [[
return function(x, i)
  return %s
end
]]

---@alias forEachFn fun(x: unknown, i: integer, self: estrela.array)

local forEachFn_template = [[
return function(x, i, self)
  %s
end
]]

---@alias reduceFn fun(acc: unknown, cur: unknown, i: integer, self: estrela.array): unknown

local reduce_template = [[
return function(acc, cur, i, self)
  return %s
end
]]

---@alias compFn fun(a: unknown, b: unknown): boolean

local compFn_template = [[
return function(a, b)
  return %s
end
]]

---@generic T: function | nil
---@param fn T | string
---@param template? string
---@return T
local function normalizeFn(fn, template)
  template = template or callback_template
  if type(fn) == "string" then
    return assert(load(template:format(fn)))()
  end
  return fn
end

---@param x integer
---@param min integer
---@param max integer
---@param strict? boolean
---@return integer
local function clamp(x, min, max, strict)
  if x < 0 then
    x = x + max + 1
  end
  if x < min then
    if not strict then
      return min
    end
  elseif x > max then
    if not strict then
      return max
    end
  end
  return x
end

---@class estrela.array
local Array = {}
Array.__index = Array
Array.__tostring = function(self)
  local str = "Array[ "
  for i, v in ipairs(self) do
    if i > 1 then
      str = str .. ", "
    end
    if type(v) == "string" then
      str = str .. string.format("%q", v)
    else
      str = str .. tostring(v)
    end
  end
  return str .. " ]"
end

--- It creates a new Array instance from a Lua list.
--- List is not copied. In other words, it simply sets the metatable.
---
--- 0. Empty table is empty list.
--- 1. Table with N consecutive integer indices starting from 1 and ending with
---    N is considered a list.
---@param list? unknown[]
---@return estrela.array
function Array.new(list)
  list = list or {}
  return setmetatable(list, Array)
end

--- It creates a new, shallow-copied Array instance from a Lua list.
---
--- 0. Empty table is empty list.
--- 1. Table with N consecutive integer indices starting from 1 and ending with
---    N is considered a list.
---
--- mapFn is A function to call on every element of the array. If provided,
--- every value to be added to the array is first passed through this function,
--- and mapFn's return value is added to the array instead.
---@param list unknown[]
---@param mapFn? string | mapFn
---@return estrela.array
function Array.from(list, mapFn)
  mapFn = normalizeFn(mapFn, mapFn_template)
  local new = {}
  if mapFn == nil then
    for i, v in ipairs(list) do
      new[i] = v
    end
  else
    for i, v in ipairs(list) do
      new[i] = mapFn(v, i)
    end
  end
  return Array.new(new)
end

--- It determines whether the passed value is an Array.
---@param x any
---@return boolean
function Array.isArray(x)
  if type(x) ~= "table" then
    return false
  end
  if getmetatable(x) == Array then
    return true
  end

  local i = 0
  for _ in pairs(x) do
    i = i + 1
    if x[i] == nil then
      return false
    end
  end
  return true
end

--- The number of elements in an array.
---@return integer
function Array:length()
  return #self
end

--- It is used to merge two or more arrays. This method does not change the
--- existing arrays, but instead returns a new array.
---@param ... unknown
---@return estrela.array
function Array:concat(...)
  local new = {}
  for _, l in ipairs({ self, ... }) do
    for _, v in ipairs(Array.isArray(l) and l or { l }) do
      table.insert(new, v)
    end
  end
  return Array.new(new)
end

--- **mutates self**
--- It shallow copies part of this array to another location in the same array
--- and returns this array without modifying its length.
---@param target integer
---@param start integer
---@param end_? integer Default: #self
---@return estrela.array
function Array:copyWithin(target, start, end_)
  local len = #self
  target = clamp(target, 1, len)
  start = clamp(start, 1, len)
  end_ = clamp(end_ or len, 1, len)
  local src = {}
  for i = start, end_ do
    table.insert(src, self[i])
  end
  for i, v in ipairs(src) do
    if self[target + i - 1] == nil then
      break
    end
    self[target + i - 1] = v
  end
  return Array.new(self)
end

--- It tests whether all elements in the array pass the test implemented by the
--- provided function.
---@param callback string | callbackFn
---@return boolean
function Array:every(callback)
  callback = normalizeFn(callback)
  for i, v in ipairs(self) do
    if not callback(v, i, self) then
      return false
    end
  end
  return true
end

--- **mutates self**
--- It changes all elements within a range of indices in an array to a static
--- value. It returns the modified array.
---@param value unknown
---@param start? integer Default: 1
---@param end_? integer Default: #self
---@return estrela.array
function Array:fill(value, start, end_)
  local len = #self
  start = clamp(start or 1, 1, len, true)
  end_ = clamp(end_ or len, 1, len, true)
  if start < 0 then
    start = 1
  end
  if end_ > len then
    end_ = len
  end
  for i = start, end_ do
    self[i] = value
  end
  return Array.new(self)
end

--- It creates a shallow copy of a portion of a given array, filtered down to
--- just the elements from the given array that pass the test implemented by the
--- provided function.
---@param callback string | callbackFn
---@return estrela.array
function Array:filter(callback)
  callback = normalizeFn(callback)
  local new = {}
  for i, v in ipairs(self) do
    if callback(v, i, self) then
      table.insert(new, v)
    end
  end
  return Array.new(new)
end

--- It returns the first element in the provided array that satisfies the
--- provided testing function. If no values satisfy the testing function, nil is
--- returned.
---@param callback string | callbackFn
---@return unknown | nil
function Array:find(callback)
  callback = normalizeFn(callback)
  for i, v in ipairs(self) do
    if callback(v, i, self) then
      return v
    end
  end
end

--- It returns the index of the first element in an array that satisfies the
--- provided testing function. If no elements satisfy the testing function, -1
--- is returned.
---@param callback string | callbackFn
---@return integer
function Array:findIndex(callback)
  callback = normalizeFn(callback)
  for i, v in ipairs(self) do
    if callback(v, i, self) then
      return i
    end
  end
  return -1
end

--- It iterates the array in reverse order and returns the value of the first
--- element that satisfies the provided testing function. If no elements satisfy
--- the testing function, nil is returned.
---@param callback string | callbackFn
---@return unknown | nil
function Array:findLast(callback)
  callback = normalizeFn(callback)
  for i = #self, 1, -1 do
    if callback(self[i], i, self) then
      return self[i]
    end
  end
end

--- It iterates the array in reverse order and returns the index of the first
--- element that satisfies the provided testing function. If no elements satisfy
--- the testing function, -1 is returned.
---@param callback string | callbackFn
---@return integer
function Array:findLastIndex(callback)
  callback = normalizeFn(callback)
  for i = #self, 1, -1 do
    if callback(self[i], i, self) then
      return i
    end
  end
  return -1
end

--- It creates a new array with all sub-array elements concatenated into it
--- recursively up to the specified depth.
--- Use `math.huge` for infinity.
---@param depth? integer Default: 1
---@return estrela.array
function Array:flat(depth)
  depth = depth or 1
  local new = {}
  local function _tbl_flatten(t, d)
    if d <= -1 then
      table.insert(new, t)
      return
    end
    for _, v in ipairs(t) do
      if Array.isArray(v) then
        _tbl_flatten(v, d - 1)
      elseif v then
        table.insert(new, v)
      end
    end
  end
  _tbl_flatten(self, depth)
  return Array.new(new)
end

--- It returns a new array formed by applying a given callback function to each
--- element of the array, and then flattening the result by one level. It is
--- identical to a map() followed by a flat() of depth 1
--- `(arr:map(...args):flat())`, but slightly more efficient than calling those
--- two methods separately.
---@param callback string | callbackFn
---@return estrela.array
function Array:flatMap(callback)
  callback = normalizeFn(callback)
  local new = {}
  for i, v in ipairs(self) do
    local result = callback(v, i, self)
    if Array.isArray(result) then
      for _, r in ipairs(result) do
        table.insert(new, r)
      end
    else
      table.insert(new, result)
    end
  end
  return Array.new(new)
end

--- It executes a provided function once for each array element.
---@param callback string | forEachFn
function Array:forEach(callback)
  callback = normalizeFn(callback, forEachFn_template)
  for i, v in ipairs(self) do
    callback(v, i, self)
  end
end

--- It determines whether an array includes a certain value among its entries,
--- returning true or false as appropriate.
---@param searchElement unknown
---@param fromIndex? integer Default: 1
---@return boolean
function Array:includes(searchElement, fromIndex)
  fromIndex = clamp(fromIndex or 1, 1, #self)
  for i = fromIndex, #self do
    if self[i] == searchElement then
      return true
    end
  end
  return false
end

--- It returns the first index at which a given element can be found in the
--- array, or -1 if it is not present.
---@param searchElement unknown
---@param fromIndex? integer Default: 1
---@return integer
function Array:indexOf(searchElement, fromIndex)
  fromIndex = clamp(fromIndex or 1, 1, #self)
  for i = fromIndex, #self do
    if self[i] == searchElement then
      return i
    end
  end
  return -1
end

--- It creates and returns a new string by concatenating all of the elements in
--- this array, separated by commas or a specified separator string. If the
--- array has only one item, then that item will be returned without using the
--- separator.
---@param separator? string Default: ""
---@return string
function Array:join(separator)
  return table.concat(self, separator)
end

--- It returns the last index at which a given element can be found in the
--- array, or -1 if it is not present. The array is searched backwards, starting
--- at fromIndex.
---@param elem unknown
---@param fromIndex? integer Default: #self
---@return integer
function Array:lastIndexOf(elem, fromIndex)
  local len = #self
  fromIndex = clamp(fromIndex or len, 1, len)
  for i = fromIndex, 1, -1 do
    if self[i] == elem then
      return i
    end
  end
  return -1
end

--- It creates a new array populated with the results of calling a provided
--- function on every element in the calling array.
---@param callback string | callbackFn
---@return estrela.array
function Array:map(callback)
  callback = normalizeFn(callback)
  local new = {}
  for i, v in ipairs(self) do
    new[i] = callback(v, i, self)
  end
  return Array.new(new)
end

--- **mutates self**
--- It removes the last element from an array and returns that element.
---@return any
function Array:pop()
  return table.remove(self)
end

--- **mutates self**
--- It adds the specified elements to the end of an array and returns the new
--- length of the array.
---@param ... unknown
---@return integer length
function Array:push(...)
  for _, v in ipairs({ ... }) do
    table.insert(self, v)
  end
  return #self
end

--- It executes a user-supplied "reducer" callback function on each element of
--- the array, in order, passing in the return value from the calculation on the
--- preceding element. The final result of running the reducer across all
--- elements of the array is a single value.
---
--- The first time that the callback is run there is no "return value of the
--- previous calculation". If supplied, an initial value may be used in its
--- place. Otherwise the array element at index 1 is used as the initial value
--- and iteration starts from the next element (index 2 instead of index 1).
---@param callback string | reduceFn
---@param initialValue? unknown
function Array:reduce(callback, initialValue)
  callback = normalizeFn(callback, reduce_template)
  local acc = initialValue
  if acc == nil then
    acc = table.remove(self, 1)
  end
  for i = 1, #self do
    acc = callback(acc, self[i], i, self)
  end
  return acc
end

--- It applies a function against an accumulator and each value of the array
--- (from right-to-left) to reduce it to a single value.
---
--- See also `Array:reduce()` for left-to-right.
---@param callback string | reduceFn
---@param initialValue? unknown
function Array:reduceRight(callback, initialValue)
  callback = normalizeFn(callback, reduce_template)
  local acc = initialValue
  if acc == nil then
    acc = table.remove(self)
  end
  for i = #self, 1, -1 do
    acc = callback(acc, self[i], i, self)
  end
  return acc
end

--- **mutates self**
--- It reverses an array `in place` and returns the reference to the same array,
--- the first array element now becoming the last, and the last array element
--- becoming the first. In other words, elements order in the array will be
--- turned towards the direction opposite to that previously stated.
---
--- To reverse the elements in an array without mutating the original array, use
--- `Array:toReversed()`.
---@return estrela.array
function Array:reverse()
  local len = #self
  for i = 1, #self / 2 do
    self[len - i + 1], self[i] = self[i], self[len - i + 1]
  end
  return Array.new(self)
end

--- **mutates self**
--- It removes the first element from an array and returns that removed element.
---@return any
function Array:shift()
  return table.remove(self, 1)
end

--- It returns a shallow copy of a portion of an array into a new array object
--- selected from start to end (end not included) where start and end represent
--- the index of items in that array. The original array will not be modified.
---@param start? integer Default: 1
---@param end_? integer Default: #self
---@return estrela.array
function Array:slice(start, end_)
  local len = #self
  start = clamp(start or 1, 1, len)
  end_ = clamp(end_ or len, 1, len)
  local new = {}
  for i = start, end_ do
    table.insert(new, self[i])
  end
  return Array.new(new)
end

--- It tests whether at least one element in the array passes the test
--- implemented by the provided function. It returns true if, in the array, it
--- finds an element for which the provided function returns true; otherwise it
--- returns false. It doesn't modify the array.
---@param callback string | callbackFn
---@return boolean
function Array:some(callback)
  callback = normalizeFn(callback)
  for i, v in ipairs(self) do
    if callback(v, i, self) then
      return true
    end
  end
  return false
end

--- It sorts the elements of an array in place and returns the reference to the
--- same array, now sorted. See `table.sort()`.
---
--- To sort the elements in an array without mutating the original array, use
--- `Array:toSorted()`.
---@param comp? string | compFn {comp} of table.sort({table}, [, {comp}])
---@return estrela.array
function Array:sort(comp)
  comp = normalizeFn(comp, compFn_template)
  table.sort(self, comp)
  return self
end

--- **mutates self**
--- It changes the contents of an array by removing or replacing existing
--- elements and/or adding new elements `in place`.
---
--- To create a new array with a segment removed and/or replaced without
--- mutating the original array, use `Array:toSpliced()`. To access part of an
--- array without modifying it, see `Array:slice()`.
---@param start integer
---@param deleteCount integer
---@param ... unknown items
---@return estrela.array
function Array:splice(start, deleteCount, ...)
  start = clamp(start, 1, #self)
  for _ = 1, deleteCount do
    table.remove(self, start)
  end
  local elements = { ... }
  for i = #elements, 1, -1 do
    table.insert(self, start, elements[i])
  end
  return Array.new(self)
end

--- It is the copying counterpart of the `Array:reverse()` method. It returns a
--- new array with the elements in reversed order.
---@return estrela.array
function Array:toReversed()
  local new = {}
  for i = #self, 1, -1 do
    table.insert(new, self[i])
  end
  return Array.new(new)
end

--- It is the copying version of the `Array:sort()` method. It returns a new
--- array with the elements sorted.
---@param comp? string | compFn {comp} of table.sort({table}, [, {comp}])
---@return estrela.array
function Array:toSorted(comp)
  comp = normalizeFn(comp, compFn_template)
  local new = {}
  for i, v in ipairs(self) do
    new[i] = v
  end
  table.sort(new, comp)
  return Array.new(new)
end

--- It is the copying version of the `Array:splice()` method. It returns a new
--- array with some elements removed and/or replaced at a given index.
---@param start integer
---@param deleteCount integer
---@param ... unknown
---@return estrela.array
function Array:toSpliced(start, deleteCount, ...)
  local len = #self
  start = clamp(start, 1, len)
  local new = {}
  for i = 1, start - 1 do
    new[i] = self[i]
  end
  for _, v in ipairs({ ... }) do
    table.insert(new, v)
  end
  for i = start + deleteCount, len do
    if self[i] == nil then
      break
    end
    table.insert(new, self[i])
  end
  return Array.new(new)
end

--- It adds the specified elements to the beginning of an array and returns the
--- new length of the array.
---@param ... unknown
---@return integer length
function Array:unshift(...)
  for i, v in ipairs({ ... }) do
    table.insert(self, i, v)
  end
  return #self
end

--- It is the copying version of using the bracket notation to change the value
--- of a given index. It returns a new array with the element at the given index
--- replaced with the given value.
---@param index integer
---@param value unknown
---@return estrela.array
function Array:with(index, value)
  index = clamp(index, 1, #self)
  local new = {}
  for i, v in ipairs(self) do
    new[i] = v
  end
  new[index] = value
  return Array.new(new)
end

return Array
