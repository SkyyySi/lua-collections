---@class generics.list : table
local list = {
	__meta = {},
	__name = "generics.list"
}

local tableunpack ---@type function
if tonumber(_VERSION:match("Lua ([0-9%.]*)")) >= 5.2 then
	tableunpack = table.unpack
else
	tableunpack = unpack
end

--- Construct a new list.
---@generic T1
---@vararg T1
---@return generics.list<T1>
function list:new(...)
	local l = {...}
	self.__index = self
	return setmetatable(l, self)
end

--- Allow calling the constuctor without `:new` (so just `list()`
--- instead of `list:new()`).
---@generic T1
---@vararg T1
---@return generics.list<T1>
function list.__meta:__call(...)
	return list:new(...)
end

--- Construct a new list from a table (instead of from varargs).
---@generic T1
---@param t T1[]
---@return generics.list<T1>
function list.__meta:from_table(t)
	return list:new(tableunpack(t))
end

--- Turn escape sequences into litterals to make them save to print.
---@param str string
---@return string
local function escape_chars(str)
	return str:gsub([[\]], [[\\]])
		:gsub("\a", "\\a")
		:gsub("\b", "\\b")
		:gsub("\f", "\\f")
		:gsub("\n", "\\n")
		:gsub("\r", "\\r")
		:gsub("\t", "\\t")
		:gsub("\v", "\\v")
end

--- Nicer and easier-to-read string conversion.
--- Instead of outputing a memory adress, the list's
--- itmes will be printend.
---
--- The string representation itself is a valid list constructor,
--- assuming that this module was imported as `generics.list`.
---@param self generics.list
---@return string
function list:__tostring()
	local output ---@type string
	local first = true

	for _, v in pairs(self) do
		if type(v) == "string" then
			v = string.format('"%s"', escape_chars(v):gsub([["]], [[\"]]))
		end

		if first then
			first = false
			output = string.format("%s(%s", self.__name, v)
		else
			output = string.format("%s, %s", output, v)
		end
	end

	output = string.format("%s)", output)
	return output
end

---@generic T1
---@param self generics.list<T1>
function list:__call()
	local i = 0
	local function iterator()
		i = i + 1
		return self[i]
	end

	return iterator
end

---@generic T1
---@param self generics.list<T1>
function list:iter()
	return self()
end

--- Create a new list and append an item to it.
---
--- Usage:
--- ```
--- local a = generics.list("foo", "bar")
--- local b = generics.list("biz", "baz")
---
--- local x = a + b -- inserts b at the end of a
---
--- print(x)
--- --stdout> generics.list("foo", "bar", generics.list("biz", "baz"))
--- ```
---@generic T1, T2
---@param self generics.list<T1>
---@param ni T2 The new item to append
---@return generics.list<T1|T2>
function list:__add(ni)
	local nl = list:new()

	for v in self() do
		table.insert(nl, v)
	end

	table.insert(nl, ni)

	return nl
end

---@generic T1, T2
---@param self generics.list<T1>
---@param ni T2 The new item to append
function list:append(ni)
	self = self + ni
end

--- Concatenation two lists into one.
---
--- Please keep in mind that this will behave differently
--- compared to using a plus.
---
--- ```
--- local a = generics.list("foo", "bar")
--- local b = generics.list("biz", "baz")
---
--- local x = a .. b -- inserts each value in b at the end of a
---
--- print(x)
--- --stdout> generics.list("foo", "bar", "biz", "baz")
--- ```
---@generic T1, T2
---@param self generics.list<T1>
---@param ni generics.list<T2> The new list to concatenate with
---@return generics.list<T1|T2>
function list:__concat(ni)
	local nl = list:new()

	for v in self() do
		table.insert(nl, v)
	end

	for _, v in pairs(ni) do
		table.insert(nl, v)
	end

	return nl
end

---@generic T1, T2
---@param self generics.list<T1>
---@param ni generics.list<T2> The new list to concatenate with
function list:concat(ni)
	self = self .. ni
end

--- Call a function for each item in the list.
---@generic T1, T2
---@param self generics.list<T1>
---@param fn fun(v: T1): T2
---@return generics.list<T1> self
function list:for_each(fn)
	for v in self() do
		fn(v)
	end
end

--- Create a new list by calling a function for each item in the list.
---@generic T1, T2
---@param self generics.list<T1>
---@param fn fun(v: T1): T2
---@return generics.list<T2> new_list
function list:map(fn)
	local nl = list:new()

	for v in self() do
		nl = nl + fn(v)
	end

	return nl
end

list.__meta.__index = list.__meta
return setmetatable(list, list.__meta)
