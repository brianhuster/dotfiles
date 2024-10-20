return {
	"nvim-treesitter/nvim-treesitter",
	run = ":TSUpdate",
	lazy = false,
	build = function()
		vim.cmd('TSInstall all')
	end,
	config = function()
		require 'nvim-treesitter.configs'.setup({
			highlight = {
				enable = true,
			},
		})
		vim.api.nvim_create_autocmd('FileType', {
			pattern = '*',
			callback = function()
				vim.cmd('TSBufEnable highlight')
			end
		})
	end
}
