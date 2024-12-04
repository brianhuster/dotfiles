-- lazy.nvim
return {
	"neovim/nvim-lspconfig",
	dependencies = "netmute/ctags-lsp.nvim",
	config = function()
		require("lspconfig").ctags_lsp.setup({})
	end,
}
