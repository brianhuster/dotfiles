---@type vim.lsp.Config
return {
	cmd = { "basics-language-server" },
	name = "basics_ls",

	settings = {
		buffer = {
			enable = false
		},
		path = {
			enable = true
		},
		snippet = {
			enable = true,
			sources = { vim.fs.joinpath(vim.fn.stdpath('data'),  'plug/friendly-snippets/package.json') }
		}
	}
}
