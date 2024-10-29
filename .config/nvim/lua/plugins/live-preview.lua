return {
	'brianhuster/live-preview.nvim',
	branch = "dev",
	dependencies = {
		{ 'nvim-telescope/telescope.nvim' },
	},
	opts = {
		sync_scroll = true,
		['telescope.autoload'] = true
	}
}
