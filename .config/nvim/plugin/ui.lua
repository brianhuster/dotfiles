if vim.g.vscode then return end

local shiftwidth = vim.fn.shiftwidth
local indent_char = '|'
local listchars = {
	tab = '| ',
	trail = '■',
	extends = '>',
	precedes = '<',
	nbsp = '␣',
	leadmultispace = indent_char .. (' '):rep(shiftwidth() - 1)
}
vim.opt.listchars = listchars
vim.api.nvim_create_autocmd('OptionSet', {
	pattern = { 'shiftwidth', 'tabstop' },
	callback = function()
		listchars.leadmultispace = indent_char .. (' '):rep(vim.fn.shiftwidth() - 1)
		vim.opt.listchars = listchars
	end
})

vim.cmd.colorscheme 'an'

---@diagnostic disable-next-line: duplicate-set-field
vim.ui.select = function(...)
	require('an').select(...)
end

vim.g.health = { style = 'float' }
if vim.fn.has('nvim-0.12') == 1 then
	require 'vim._extui'.enable {}
end
