return {
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			require("dapui").setup()
		end
	},
	{
		"leoluz/nvim-dap-go",
	},
	{
		--- Debug Nvim Lua code
		"jbyuki/one-small-step-for-vimkind",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
	}
}
