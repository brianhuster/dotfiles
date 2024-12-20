return {
	'justinmk/vim-dirvish',
	config = function()
		vim.fn['dirvish#add_icon_fn'](function(path)
			local icon = require('mini.icons').get
			return path:sub(-1) == '/' and icon('directory', '') or icon('file', path)
		end)
	end,
	dependencies = {
		{
			'brianhuster/dirvish-git.nvim',
			branch = 'dev',
		},
		'brianhuster/dirvish-do.nvim',
		'echasnovski/mini.icons'
		-- {
		-- 	'miversen33/netman.nvim',
		-- 	config = function()
		-- 		require('netman')
		-- 	end
		-- },
	}
}
