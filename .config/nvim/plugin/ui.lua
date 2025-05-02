vim.cmd.colorscheme 'an'

---@diagnostic disable-next-line: duplicate-set-field
vim.ui.select = function(...)
	require('an').select(...)
end

vim.g.health = { style = 'float' }
require 'vim._extui'.enable {
	msg = {
		pos = 'box'
	}
}
