return {
	'cohama/lexima.vim',
	config = function()
		vim.g.lexima_enable_endwise_rules = false
	end,
	event = 'InsertEnter',
}
