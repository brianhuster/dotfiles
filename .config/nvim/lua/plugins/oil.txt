return {
	"stevearc/oil.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},

	config = function()
		require("oil").setup({
			view_options = {
				show_hidden = true,
			},
			float = {
				-- Padding around the floating window
				padding = 2,
				max_width = 90,
				win_options = {
					winblend = 0,
				},
			},
			win_options = {
				signcolumn = "yes:2",
			},
		})
		vim.keymap.set('n', '<M-e>', require('oil').toggle_float)
		vim.keymap.set('i', '<M-e>', require('oil').toggle_float)
		vim.keymap.set('t', '<M-e>', require('oil').toggle_float)
		vim.keymap.set('x', '<M-e>', require('oil').toggle_float)
	end,
}
