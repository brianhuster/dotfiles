vim.cmd.colorscheme 'an'
vim.ui.select = function(...) ---@diagnostic disable-line: duplicate-set-field
	require 'an'.select(...)
end
