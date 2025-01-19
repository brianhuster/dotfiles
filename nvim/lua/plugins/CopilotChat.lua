return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{
				"github/copilot.vim",
				config = function()
					vim.keymap.set('i', '<M-CR>', 'copilot#Accept("\\<CR>")', {
						expr = true,
						replace_keycodes = false
					})
					vim.keymap.set('i', '<M-w>', '<Plug>(copilot-accept-word)', {
						expr = true,
						replace_keycodes = false
					})
					vim.keymap.set('i', '<M-l>', '<Plug>(copilot-accept-line)', {
						expr = true,
						replace_keycodes = false
					})
					vim.g.copilot_no_tab_map = true
				end
			},
			{ "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
		},
		build = "make tiktoken", -- Only on MacOS or Linux
		cmd = 'CopilotChat',
		opts = { debug = true }
		-- config = function()
		-- 	vim.api.nvim_create_user_command('CopilotChat', function()
		-- 		require 'CopilotChat'.setup {
		-- 			debug = true
		-- 		}
		-- 		require 'CopilotChat'.open()
		-- 	end, {})
		-- end
	},
}
