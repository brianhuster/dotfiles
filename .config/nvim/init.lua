vim.opt.runtimepath:prepend("~/.config/nvim")
require('keymaps')
require('settings')
require('ui')
require('ibus')
if not vim.g.vscode then
	require('plugins-managers')
end
