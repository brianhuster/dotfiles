if vim.loader then
	vim.loader.enable()
end
local vimrc = vim.fn.stdpath('config') .. '/vimrc'
vim.cmd.source(vimrc)
require 'ui'
require 'vscode'
require 'lsp'
require 'treesitter'

vim.api.nvim_create_autocmd('BufRead', {
	pattern = '*.txt',
	callback = function(arg)
		print("arg.file", arg.file)
		if arg.file:match('/doc/*.txt$') then
			vim.bo.filetype = 'help'
		end
	end
})
