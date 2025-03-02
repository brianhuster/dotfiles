return {
	{
		'cohama/lexima.vim',
		config = function()
			vim.g.lexima_enable_endwise_rules = false
		end,
	},
	'brianhuster/nvim-treesitter-endwise',
	-- {
	-- 	'echasnovski/mini.pairs',
	-- 	config = function()
	-- 		require('mini.pairs').setup()
	-- 	end
	-- }
	-- {
	-- 	'windwp/nvim-autopairs',
	-- 	event = "InsertEnter",
	-- 	opts = {
	-- 		map_cr = true
	-- 	},
	-- 	config = function()
	-- 		local npairs = require('nvim-autopairs')
	-- 		npairs.setup({ map_cr = true })
	-- 		-- skip it, if you use another global object
	-- 	end,
	-- },
	{
		'windwp/nvim-ts-autotag',
		event = "InsertEnter",
		config = true
	}
}
