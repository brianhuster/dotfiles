return {
	cmd = { 'lua-language-server' },
	filetypes = { 'lua' },
	rootdir = require('an.lua').find_root,
	settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT',
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
					"${3rd}/luv/library",
					"${3rd}/busted/library",
				}
			}
		}
	},
	on_attach = function(client, bufnr)
		require('an.lua').auto_require(client, bufnr)
	end,
}
