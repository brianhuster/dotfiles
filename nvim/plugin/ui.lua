vim.cmd.colorscheme 'an'
---@diagnostic disable-next-line: duplicate-set-field
vim.ui.select = function(...)
	require('an').select(...)
end
