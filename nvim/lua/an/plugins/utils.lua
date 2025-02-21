return {
	{
		'brianhuster/autosave.nvim',
		event = "BufRead",
	},
	{
		'OXY2DEV/patterns.nvim'
	},
	{
		--- Auto generate code documentation
		'danymat/neogen',
		config = true,
		event = 'BufRead'
	},
	{
		"folke/ts-comments.nvim",
		opts = {},
		event = "FileType",
		enabled = vim.fn.has("nvim-0.10.0") == 1,
	},
	{
		'lambdalisue/vim-suda',
	},
	{
		'brianhuster/snipexec.nvim'
	},
	{
		'uga-rosa/ccc.nvim'
	},
	{
		'glacambre/firenvim',
		build = function()
			vim.fn['firenvim#install'](0)
		end,
		config = function()
			vim.g.firenvim_config = {
				globalSettings = { alt = "all" },
				localSettings = {
					[".*"] = {
						cmdline  = "neovim",
						content  = "text",
						priority = 0,
						selector = "textarea",
						takeover = "never"
					}
				}
			}
		end
	},
	{
		"alexxGmZ/player.nvim",
	},
	{
		'brianhuster/live-preview.nvim',
		branch = "dev",
		config = function()
			require('livepreview.config').set {
				sync_scroll = false,
				picker = "fzf-lua",
				browser = "firefox",
			}
		end
	},
	{ 'equalsraf/neovim-gui-shim' }
}
