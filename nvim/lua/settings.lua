vim.o.mouse = 'a'
vim.o.number = true
vim.o.expandtab = false
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.cursorline = false
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.history = 5000
vim.o.clipboard = 'unnamedplus'
vim.o.autowriteall = true
vim.o.modeline = false
vim.o.backspace = 'indent,eol,start'
vim.g.mapleader = ' '
vim.cmd [[
	aunmenu PopUp
  	autocmd! nvim_popupmenu
]]
if vim.fn.has('nvim') == 1 then
	vim.filetype.add({
		pattern = {
			['.*%.ejs'] = 'html',
			['.*/doc/.+%.txt'] = 'help'
		}
	})
end
