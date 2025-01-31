return {
	'brianhuster/live-preview.nvim',
	branch = "dev",
	-- dependencies = {
	-- 	"brianhuster/autosave.nvim",
	-- 	branch = "dev",
	-- 	opts = {
	-- 		disable_inside_paths = {
	-- 			vim.fn.stdpath('config'),
	-- 		},
	-- 	}
	-- },
	config = function()
		require('livepreview.config').set {
			sync_scroll = false,
			picker = "fzf-lua",
			browser = "firefox",
		}
	end
}
