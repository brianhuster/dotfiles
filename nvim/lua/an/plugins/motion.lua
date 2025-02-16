return {
	{
		'kylechui/nvim-surround',
		opts = true,
		event = "BufRead",
	},
	{
		'justinmk/vim-sneak',
		config = function()
			vim.g['sneak#label'] = 1
		end
	},
	{
		'mg979/vim-visual-multi',
		config = function()
			vim.cmd [[
			let g:vm_mouse_mappings    = 1
			let g:vm_theme             = 'iceblue'

			let g:vm_maps = {}
			let g:vm_maps["undo"]      = 'u'
			let g:vm_maps["redo"]      = '<c-r>'
		]]
		end
	},
	{
		"christoomey/vim-tmux-navigator",
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
		},
		keys = {
			{ "<c-w>h", "<cmd><C-U>TmuxNavigateLeft<cr>" },
			{ "<c-w>j", "<cmd><C-U>TmuxNavigateDown<cr>" },
			{ "<c-w>k", "<cmd><C-U>TmuxNavigateUp<cr>" },
			{ "<c-w>l", "<cmd><C-U>TmuxNavigateRight<cr>" },
			{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
		},
	}
}
