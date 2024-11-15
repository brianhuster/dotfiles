vim.keymap.set('i', '<M-CR>', 'call copilot#Accept("\\<CR>")', {
	expr = true,
	replace_keycodes = false
})
vim.keymap.set('i', '<M-w>', '<Plug>(copilot-accept-word)', {
	expr = true,
	replace_keycodes = false
})
vim.keymap.set('i', '<M-l>', '<Plug>(copilot-accept-line)', {
	expr = true,
	replace_keycodes = false
})
vim.g.copilot_no_tab_map = true
