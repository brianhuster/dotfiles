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
			dynamic_root = false,
			sync_scroll = true,
			picker = "fzf-lua",
			browser = "firefox",
		}
	end
}
