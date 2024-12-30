function LuaComplete(findstart, base)
	if findstart == 1 then
		local lua_omni = vim.lua_omnifunc(findstart)
		local ts_omni = vim.treesitter.query.omnifunc(findstart, base)
		return lua_omni > ts_omni and lua_omni or ts_omni
	end
	return vim.list_extend(vim.lua_omnifunc(findstart), vim.treesitter.query.omnifunc(findstart, base))
end

if vim.bo.omnifunc == '' then
	vim.bo.omnifunc = 'v:lua.LuaComplete'
end
