local ui_info = vim.api.nvim_get_ui_info()
if ui_info.ext_messages then
	vim.notify("You are using a GUI with ext_messages, so noice.nvim will be disabled")
	return
end
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
