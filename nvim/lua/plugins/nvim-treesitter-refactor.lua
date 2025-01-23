return {
	'nvim-treesitter/nvim-treesitter-refactor',
	dependencies = {
		{ 'nvim-treesitter/nvim-treesitter' },
	},
	event = 'BufRead',
	config = function()
		require 'nvim-treesitter.configs'.setup({
			refactor = {
				highlight_definitions = { enable = true },
				highlight_current_scope = { enable = false },
				smart_rename = {
					enable = true,
					keymaps = {
						smart_rename = "<leader>rn",
					},
				},
				navigation = {
					enable = true,
					keymaps = {
						goto_definition = "gd",
						list_definitions = "gnD",
						list_definitions_toc = "gO",
						goto_next_usage = "<a-*>",
						goto_previous_usage = "<a-#>",
					},
				},
			},
		})
	end
}
