---@author: SkyyySi 2022-06-08 19:39:26

local tableunpack ---@type function
if tonumber(_VERSION:match("Lua ([0-9%.]*)")) >= 5.2 then
	tableunpack = table.unpack
else
	tableunpack = unpack
end

--- TL;DR: A usage example is at the bottom.
---
--- A simple `enum` implementation. For comparison, this
--- is not like a Java `enum`, but rather like a C# one.
--- In other words: this is basically just a "named integer",
--- not some complex data structure basically equivalent to a class.
---
---
---
--- *When is this useful / what do I need this for?*
---
--- An `enum` comes in handy when you want to store different
--- "outcomes" of something. For example, lets assume we have
--- a class named `task`. A `task` could have different conditions:
---
---  - not started
---  - work in progress
---  - completed successfully
---  - failed
---
--- Now, if we wanted to describe this, the first that probably
--- comes to mind is using a table:
---
--- ```
--- local bad_task_enum = { "not_started", "wip", "success", "fail" }
--- local task_status
--- ```
---
--- This 'works', but notice how unreadable this is when actually
--- accessing a field:
---
--- ```
--- local function on_task_fail()
--- 	task_status = bad_task_enum[4]
--- end
--- ```
---
--- Notice how this gives us no idea whatsoever to what value we
--- are actually setting `task_status` to. This might not be that
--- big issue in this example, but what if you wanted to add a new
--- possible status anywhere but at the end of the `enum`? Well,
--- your only option is to now manually update every spot in your
--- code where you used any value behind the one you just added.
---
--- ```
--- 	task_status = bad_task_enum[4]
--- ```
---
--- Needless to say, this can take a ton of time to do and
--- will probably become very, very mind numbing very quickly.
--- Luckily, `enum`s come to the rescue!
---
--- ---
---
--- `enum`s are specifically designed to make this use of a string list
--- way nicer to write and later read. Or, at least, this implementation
--- is ;)
---
--- ```
--- -- You can use either a parameter list (as shown in this example), or pass
--- -- an array / a table of strings. The resoult will be functionally equivalent.
--- local good_task_enum = generics.enum("not_started", "wip", "success", "fail")
---
--- function on_task_fail()
--- 	-- This value can either be used by using the
--- 	-- MY_ENUM.MY_FIELD or the MY_ENUM["MY_FIELD"] syntax.
--- 	task_status = good_task_enum.fail
--- end
--- ```
---@generic T1
---@class generics.enum<T1> : generics.enum.meta
local enum = {
	__name = "generics.enum"
}

---@class generics.enum.meta
local enum_meta = {}
enum_meta.__index = enum_meta ---@type generics.enum.meta

--- Constructor.
---@generic T1
---@param self generics.enum
---@vararg T1
---@return generics.enum<T1>
function enum_meta:new(...)
	local t = {}

	for k, v in pairs {...} do
		t[v] = k
	end

	self.__index = self
	return setmetatable(t, self)
end

--- Constructor shorthand.
enum_meta.__call = enum_meta.new

--- Alternative, table-based constructor.
---@generic T1
---@param self generics.enum
---@param t table<number, T1>
---@return generics.enum<T1>
function enum_meta:from_table(t)
	t = t or {}

	return enum_meta:new(tableunpack(t))
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
--- Instead of outputing a memory adress, the enums's
--- keys will be printend.
---
--- The string representation itself is a valid list constructor,
--- assuming that this module was imported as `generics.enum`.
---@param self generics.enum
---@return string
function enum:__tostring()
	local output ---@type string
	local first = true

	for k, _ in pairs(self) do
		if type(k) == "string" then
			k = string.format('"%s"', escape_chars(k):gsub([["]], [[\"]]))
		end

		if first then
			first = false
			output = string.format("%s(%s", self.__name, k)
		else
			output = string.format("%s, %s", output, k)
		end
	end

	return string.format("%s)", output)
end

-- TODO: Port __add(), append(), __concat() and concat() methods into enum

---@param self generics.enum
function enum:__newindex(k, v)
	if k == nil then
		k = #self + 1
	end

	self[v] = k
end

--- The iterator number needs to be stored externally.
local iterator = 0
--- Make the enum iterable in imperative for-loops.
---
--- Usage:
---
--- ```
--- local my_enum = generics.enum("foo", "bar", "biz", "baz", "lua")
---
--- for i in my_enum do
--- 	print(i)
--- end
--- ```
---@generic T1
---@param self generics.enum<T1>
function enum:__call()
	if #self < iterator then
		iterator = iterator + 1
		return self[iterator]
	end

	iterator = 0
end

--- Declarative / functional for-loop.
---
--- Usage:
---
--- ```
--- local my_enum = generics.enum("foo", "bar", "biz", "baz", "lua")
---
--- function do_something(value)
--- 	print(value)
--- end
---
--- my_enum:for_each(do_something)
--- ```
---@generic T1
---@param self generics.enum<T1>
---@param fn fun(value: string)
function enum:for_each(fn)
	for i in self do
		fn(i)
	end
end

return setmetatable(enum, enum_meta)
