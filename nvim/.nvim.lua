vim.lsp.config.lua_ls = {
	runtime = {
		version = 'LuaJIT'
	},

	settings = {
		Lua = {
			workspace = {
				library = vim.list_extend(vim.lsp.config.lua_ls.settings.Lua.workspace.library,
					vim.fn.glob(vim.fn.stdpath('data') .. '/lazy/*', true, true))
			}
		}
	}
}
