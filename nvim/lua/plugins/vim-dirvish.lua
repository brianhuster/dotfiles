return {
	'justinmk/vim-dirvish',
	config = function()
		vim.g.dirvish_mode = ':sort ,^.*[\\/],'
	end,
	dependencies = {
		{
			'brianhuster/dirvish-git.nvim',
			branch = 'dev',
		},
		'brianhuster/dirvish-do.nvim',
		-- {
		-- 	'miversen33/netman.nvim',
		-- 	config = function()
		-- 		require('netman')
		-- 	end
		-- },
	}
}
