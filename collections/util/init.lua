---@param module string
---@param prefix? string
local function import(module, prefix)
	prefix = prefix or debug.getinfo(2, "S").source:sub(2):match("(.*/)")
	return dofile(string.format("%s/%s/init.lua", prefix, module))
end

return {
	lambda = import("lambda")
}
