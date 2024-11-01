return {
	'brianhuster/live-preview.nvim',
	branch = "dev",
	dependencies = {
		{ 'nvim-telescope/telescope.nvim' },
	},
	opts = {
		commands = {
			start = "LiveStart",
			stop = "LiveStop",
		},
		sync_scroll = true,
		telescope = {
			autoload = true,
		}
	}
}
