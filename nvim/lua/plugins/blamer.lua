return {
	'APZelos/blamer.nvim',
	event = 'BufRead',
	config = function()
		vim.g.blamer_date_format = '%y/%m/%d %H:%M'
		vim.g.blamer_enabled = 1
	end
}
