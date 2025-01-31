return {
	'brianhuster/supermaven-nvim',
	config = function()
		require 'supermaven-nvim'.setup {
			keymaps = {
				accept_suggestion = "<M-CR>",
				accept_word = "<M-w>",
			},
		}
		require("supermaven-nvim.api").use_free_version()
	end,
	event = 'InsertEnter',
}
