return {
	{
		"atiladefreitas/lazyclip",
		config = function()
			require("lazyclip").setup()
		end,
		keys = {
			{ "<leader>cb", ":lua require('lazyclip').show_clipboard()<CR>", desc = "Open Clipboard Manager" },
		},
	},
}
