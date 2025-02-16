return {
	{
		"ibhagwan/fzf-lua",
		dependencies = {
			'echasnovski/mini.icons',
			{
				'junegunn/fzf',
				build = function()
					vim.fn['fzf#install']()
				end,
				config = function()
					vim.g.loaded_fzf = 1
				end
			},
		},
		-- optional for icon support
		config = function()
			vim.keymap.set('n', '<leader>ff', function() require('fzf-lua').files() end, { desc = 'Find files' })
			vim.keymap.set('n', '<leader>fg', function() require('fzf-lua').live_grep() end, { desc = 'Find live grep' })
		end
	},
	{
		'brianhuster/compick.nvim',
	},
	{
		'echasnovski/mini.pick',
		config = true,
	},
	-- {
	-- 	"nvim-telescope/telescope.nvim",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		"nvim-treesitter/nvim-treesitter",
	-- 		"nvim-telescope/telescope-media-files.nvim",
	-- 	},
	-- }
}
