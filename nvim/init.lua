vim.opt.runtimepath:prepend("~/.config/nvim")
if vim.loader then
	vim.loader.enable()
end
local vimrc = vim.fs.joinpath(vim.fn.stdpath('config'), 'vimrc')
vim.cmd.source(vimrc)
require('ui')
require('vscode')
require('plugins-manager')
vim.filetype.add({
	pattern = {
		['.*%.ejs'] = 'html',
		['.*/doc/.+%.txt'] = 'help'
	}
})

vim.api.nvim_create_autocmd('BufRead', {
	pattern = '*/doc/*.txt',
	callback = function()
		vim.fn.py3eval('print("Hello world")')
	end
})
