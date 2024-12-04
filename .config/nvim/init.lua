vim.opt.runtimepath:prepend("~/.config/nvim")
if vim.loader then
	vim.loader.enable()
end
vim.cmd.source('vimrc')
require('ui')
require('vscode')
require('plugins-managers')
