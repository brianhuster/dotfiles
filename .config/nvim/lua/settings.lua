vim.opt.mouse = 'a'
vim.opt.number = true
vim.opt.expandtab = false
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.cursorline = false
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.history = 5000
vim.opt.clipboard = 'unnamedplus'
vim.opt.autowriteall = true
vim.opt.modeline = false
vim.g.mapleader = ' '
vim.filetype.add({
	pattern = {
		['.*%.ejs'] = 'html',
		['.*/doc/.+%.txt'] = 'help'
	}
})
vim.api.nvim_create_autocmd('FileType', {
	pattern = '*',
	callback = function()
		vim.cmd('TSBufEnable highlight')
	end
})
