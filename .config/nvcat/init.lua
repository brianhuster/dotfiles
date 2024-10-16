vim.o.ts = 4
vim.o.expandtab = false
vim.cmd.source(vim.fn.stdpath('config') .. '/colors/an.lua')
vim.api.nvim_create_autocmd('FileType', {
	callback = function()
		pcall(vim.treesitter.start)
	end
})
