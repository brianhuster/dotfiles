if vim.loader then
	vim.loader.enable()
end
local vimrc = vim.fn.stdpath('config') .. '/vimrc'
vim.cmd.source(vimrc)
require('ui')
require('vscode')
require('lsp')
require('plugins-manager')
require('treesitter')
