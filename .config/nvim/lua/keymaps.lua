function TerminalMode()
	local buf = vim.api.nvim_get_current_buf()
	if vim.api.nvim_get_option_value('buflisted', { buf = buf }) == 'terminal' then
		vim.cmd('startinsert')
		return
	end
	local term_win = -1
	for win = 1, #vim.api.nvim_tabpage_list_wins(0) do
		vim.fn.winbufnr(win)
		if vim.api.nvim_get_option_value('buflisted', { buf = buf }) == 'terminal' then
			term_win = win
			break
		end
	end
	if term_win == -1 then
		vim.cmd('belowright split | terminal')
		vim.wo.number = false
		vim.o.winheight = 12
	else
		vim.cmd(term_win .. 'wincmd w')
	end
	vim.cmd('startinsert')
end

-- Terminal keybindings
vim.keymap.set('n', 't', function() TerminalMode() end)
vim.keymap.set('x', 't', function() TerminalMode() end)
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { silent = true })

-- delete selected text without copying it
vim.keymap.set('n', '<BS>', '"_d', { silent = true })
vim.keymap.set('x', '<BS>', '"_d', { silent = true })
vim.keymap.set('n', '<Del>', '"_d', { silent = true })
vim.keymap.set('x', '<Del>', '"_d', { silent = true })

-- Delete a line without copying it
vim.keymap.set('n', '<BS><BS>', '"_dd', { silent = true })
vim.keymap.set('x', '<BS><BS>', '"_dd', { silent = true })
vim.keymap.set('n', '<Del><Del>', '"_dd', { silent = true })
vim.keymap.set('x', '<Del><Del>', '"_dd', { silent = true })

-- Delete until the end of the line without copying it
vim.keymap.set('n', '<BS>$', '"_D', { silent = true })
vim.keymap.set('x', '<BS>$', '"_D', { silent = true })
vim.keymap.set('n', '<Del>$', '"_D', { silent = true })
vim.keymap.set('x', '<Del>$', '"_D', { silent = true })
