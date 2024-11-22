return {
	"NeogitOrg/neogit",
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
	config = true
}
