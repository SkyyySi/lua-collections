---@author: Simon 2022-06-18 13:19:44
--- A wrapper for any lua data type.

---@generic T1
---@class generics.wrapper<T1> : generics.wrapper.meta
---@field object T1
local wrapper = {}

---@class generics.wrapper.meta
local wrapper_meta = {}
wrapper_meta.__index = wrapper_meta ---@type generics.wrapper.meta

---@generic T1
---@param object T1
---@return generics.wrapper<T1>
function wrapper_meta:new(object)
	local lua_ver = tonumber(_VERSION:gsub("^Lua%s*", "")) ---@type number

	local proxy = {}
	local meta = {}

	meta.__index = object
	function meta:__newindex(k, v) object[k] = v end
	function meta:__call(...) return object(...) end
	function meta:__tostring() return tostring(object) end

	if lua_ver >= 5.2 then
		function meta:__len() return #object end
	end

	return setmetatable(proxy, meta)
end

wrapper_meta.__call = wrapper_meta.new

return setmetatable(wrapper, wrapper_meta)
