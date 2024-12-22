return {
	'RRethy/nvim-treesitter-endwise',
	depends = { 'nvim-treesitter/nvim-treesitter' },
	config = function()
		require('nvim-treesitter.configs').setup {
			endwise = {
				enable = true,
			},
		}
	end
}
