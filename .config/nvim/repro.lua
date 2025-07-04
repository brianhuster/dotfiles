vim.opt.packpath:append(vim.fn.stdpath('data') .. '/site')
local github = function(name)
	return 'https://github.com/' .. name
end
vim.pack.add {
	{
		src = github 'nvim-treesitter/nvim-treesitter',
		version = 'main'
	},
	{
		src = github 'nvim-treesitter/nvim-treesitter-textobjects',
		version = 'master'
	},
	github 'neovim/nvim-lspconfig'
}
