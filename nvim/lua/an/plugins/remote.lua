return {
	{
		"amitds1997/remote-nvim.nvim",
		version = "*",      -- Pin to GitHub releases
		dependencies = {
			"nvim-lua/plenary.nvim", -- For standard functions
			"MunifTanjim/nui.nvim", -- To build the plugin UI
		},
		config = true,
		cmd = 'Packadd remote-nvim.nvim'
	},
	-- {
	-- 	'miversen33/netman.nvim',
	-- 	config = function()
	-- 		require('netman')
	-- 	end,
	-- 	cmd = 'Netman'
	-- }
}
