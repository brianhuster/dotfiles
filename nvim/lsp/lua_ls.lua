return {
	cmd = { 'lua-language-server' },
	filetypes = { 'lua' },
	rootdir = require('an.lua').find_root,
	runtime = {
		version = 'LuaJIT'
	},
	settings = {
		Lua = {
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
					"${3rd}/luv/library",
					"${3rd}/busted/library",
				}
			}
		}
	}
}
