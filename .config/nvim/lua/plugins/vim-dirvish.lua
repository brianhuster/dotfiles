return {
	'justinmk/vim-dirvish',
	dependencies = {
		{
			'brianhuster/dirvish-git.nvim',
			branch = 'dev',
		},
		'brianhuster/dirvish-do.nvim',
		{
			'miversen33/netman.nvim',
			config = function()
				require('netman')
			end
		},
		'bounceme/remote-viewer'
	}
}
