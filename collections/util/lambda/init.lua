local function lambda(expr)
	local args, body = expr:match("|([^|]*)|(.*)")
	return load(string.format("return function(%s)return %s;end", args, body))()
end

return lambda
