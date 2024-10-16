vim.cmd(':colorscheme torte')

vim.api.nvim_create_autocmd('BufEnter', {
	pattern = '*',
	callback = function()
		if vim.bo.buftype == 'terminal' then
			vim.wo.number = false
			vim.o.winheight = 12
		elseif vim.bo.buftype == 'nofile' then
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, true, true), 'n', true)
		else
			vim.o.winheight = 100
		end
	end
})
