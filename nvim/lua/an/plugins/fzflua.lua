return {
	"ibhagwan/fzf-lua",
	dependencies = {
		'echasnovski/mini.icons',
		{
			'junegunn/fzf',
			build = function()
				vim.fn['fzf#install']()
			end
		},
	},
	-- optional for icon support
	config = function()
		-- calling `setup` is optional for customization
		vim.keymap.set('n', '<leader>ff', function() require('fzf-lua').files() end, {})
		vim.keymap.set('n', '<leader>fg', function() require('fzf-lua').live_grep() end, {})
	end
}
