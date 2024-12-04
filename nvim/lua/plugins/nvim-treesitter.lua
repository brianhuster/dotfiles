return {
	"nvim-treesitter/nvim-treesitter",
	run = ":TSUpdate",
	lazy = false,
	build = function()
		vim.cmd.TSInstall('all')
	end,
	opts = {
		highlight = {
			enable = true,
		},
	}
}
