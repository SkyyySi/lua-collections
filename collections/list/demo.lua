#!/usr/bin/env lua5.4
local list = dofile("./init.lua")

local l1 = list("foo", "bar", "biz", "baz", "lua")
local l2 = list:from_table { "foo", "bar", "biz", "baz", "lua" }

print("Imperative iteration:")
for i in l1 do
	print(i)
end

print("\n====================================\n")

print("Declarative / functional iteration:")
l1:for_each(function(i) print(i) end)
