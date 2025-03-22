vim.cmd.colorscheme 'an'
vim.ui.select = function(...)
	require 'an'.select(...)
end
