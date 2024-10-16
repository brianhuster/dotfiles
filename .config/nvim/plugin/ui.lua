if vim.g.vscode then return end

vim.cmd.colorscheme 'an'

---@diagnostic disable-next-line: duplicate-set-field
vim.ui.select = function(...)
	require('an').select(...)
end

vim.g.health = { style = 'float' }
if vim.fn.has('nvim-0.12') == 1 then
	require 'vim._extui'.enable {}
end
