vim.cmd.colorscheme 'an'
---@diagnostic disable-next-line: duplicate-set-field
vim.ui.select = function(...)
	require('an').select(...)
end

local extui = require 'vim._extui'
if extui then
	extui.enable {}
	vim.o.cmdheight = 0
end
