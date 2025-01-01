return {
	"ibhagwan/fzf-lua",
	dependencies = {
		'echanovski/mini.icons',
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
		vim.keymap.set('n', '<leader>ff', require('fzf-lua').files, {})
		vim.keymap.set('n', '<leader>fg', require('fzf-lua').live_grep, {})
	end
}
