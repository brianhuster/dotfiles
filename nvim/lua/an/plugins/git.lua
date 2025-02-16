return {
	{
		'f-person/git-blame.nvim',
		event = "BufRead",
	},
	-- {
	-- 	"lewis6991/gitsigns.nvim",
	-- 	event = "BufRead",
	-- 	opts = {
	-- 		current_line_blame = true,
	-- 	}
	-- },
	-- { 'tanvirtin/vgit.nvim', config = true },
	{
		"tpope/vim-fugitive"
	},
	{
		"NeogitOrg/neogit",
		cmd = 'Neogit',
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			{
				"sindrets/diffview.nvim",
				config = function()
					require("diffview").setup({
						use_icons = false,
					})
				end,
			},
		},
	},
	{
		'echasnovski/mini.diff',
		opts = {
			view = {
				style = 'sign'
			}
		},
		event = 'BufRead',
	}
}
