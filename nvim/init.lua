vim.opt.runtimepath:prepend("~/.config/nvim")
if vim.loader then
	vim.loader.enable()
end
require('keymaps')
require('settings')
require('ibus')
require('ui')
require('vscode')
require('plugins-managers')
