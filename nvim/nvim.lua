if vim.loader then
	vim.loader.enable()
end
require 'vim.loader'
vim.g.loaded_perl_provider = 1
require 'an.ui'
require 'an.vscode'
require 'an.lsp'
require 'an.treesitter'
