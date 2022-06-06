---@class generics.class : generics.class.meta
local class = {
	__name = "generics.class"
}

---@class generics.class.meta
---@field new fun(self: generics.class.meta, t?: table)
class.__meta = {}

---@class generics.class.instance : generics.class
---@field constructor fun(self: generics.class.instance, ...)
class.__meta.__instance = {}

---@generic T1
---@param self generics.class.meta
---@param t? table
---@return generics.class<T1> instance
function class.__meta:new(t)
	t = t or {}
	self.__index = self
	return setmetatable(t, self)
end

---@generic T1
---@param self generics.class.meta
---@vararg T1
---@return generics.class<T1> instance
function class.__meta:__call(...)
	return self:new(...)
end

---@generic T1, T2
---@param self generics.class<T1>
---@vararg any
---@return T2
function class:__call(...)
	local instance = {} ---@type generics.class.instance
	self.__index = self
	setmetatable(instance, self)

	if instance.constructor then
		instance:constructor(...)
	end

	return instance
end

class.__meta.__index = class.__meta
setmetatable(class, class.__meta)
return class
