vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
	pattern = '**/doc/*.txt',
	callback = function()
		vim.cmd.setfiletype 'help'
	end
})
