return {
	'brianhuster/live-preview.nvim',
	branch = "dev",
	config = function()
		require('livepreview.config').set {
			dynamic_root = false,
			sync_scroll = true,
			picker = "fzf-lua",
			browser = "firefox",
		}
	end
}
