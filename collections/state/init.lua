---@author: SkyyySi 2022-06-07 21:28:08
--- A dynamic state management solution.

---@generic T1
---@class generics.state<T1> : generics.state.meta
---@field object T1
---@field on_update fun(object: T1)
local state = {}

---@class generics.state.meta
local state_meta = {}
state_meta.__index = state_meta ---@type generics.state.meta

--- Constructor
---@generic T1
---@param self generics.state
---@param object T1 The object which should be state managed
---@param on_update fun(object: T1) A callback that gets fired when the object changes
---@return generics.state<T1>
function state_meta:new(object, on_update)
	local t = {
		object = object,
		on_update = on_update,
	}

	--self.__index = self
	return setmetatable(t, state)
end

--- Constructor shorthand
state_meta.__call = state_meta.new

function state:__index(k)
	print("__index called")
	self.on_update(self.object)
	return self[k]
end

function state:__newindex(k, v)
	print("__newindex called")
	--error("A state object cannot be altered directly - use :set and :get for that.")

	self.on_update(self.object)
	self[k] = v
end

---@generic T1
---@param self generics.state
---@return T1 object
function state:get()
	return self.object
end

---@generic T1
---@param self generics.state
---@param value T1
function state:set(value)
	self.object = value
end

return setmetatable(state, state_meta)
