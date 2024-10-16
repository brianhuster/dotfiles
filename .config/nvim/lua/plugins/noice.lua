return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {
		-- add any options here
	},
	dependencies = {
		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		"MunifTanjim/nui.nvim",
		{
			'echasnovski/mini.notify',
			version = false,
			config = function()
				require('mini.notify').setup()
			end,
		}
	}
}
