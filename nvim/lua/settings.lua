vim.o.mouse = 'a'
vim.o.number = true
vim.o.expandtab = false
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.cursorline = false
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.clipboard = 'unnamedplus'
vim.o.autowriteall = true
vim.o.modeline = false
vim.o.backspace = 'indent,eol,start'
vim.g.mapleader = ' '
vim.o.foldexpr = "v:lua.vim.lsp.foldexpr()"
vim.cmd.language({
	args = { 'vi_VN.utf-8' },
	mods = { silent = true }
})
vim.cmd [[
	aunmenu PopUp
  	autocmd! nvim_popupmenu
]]
vim.filetype.add({
	pattern = {
		['.*%.ejs'] = 'html',
		['.*/doc/.+%.txt'] = 'help'
	}
})
