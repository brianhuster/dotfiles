return {
	'Exafunction/codeium.vim',
	config = function()
		vim.g.codeium_disable_bindings = 1
		vim.keymap.set('i', '<M-CR>', function() return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
		vim.keymap.set('i', '<M-w>', function() return vim.fn['codeium#AcceptNextWord()'](1) end,
			{ expr = true, silent = true })
		vim.keymap.set('i', '<M-l>', function() return vim.fn['codeium#AcceptNextLine'](-1) end,
			{ expr = true, silent = true })
	end
}
