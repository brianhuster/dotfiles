local function terminal()
	if vim.fn.has('nvim') == 0 then
		return
	end
	if vim.bo.buftype == 'terminal' then
		vim.cmd('startinsert')
		return
	end
	local term_win = -1
	for win = 1, #vim.api.nvim_tabpage_list_wins(0) do
		vim.api.nvim_set_current_win(vim.api.nvim_tabpage_list_wins(0)[win])
		if vim.bo.buftype == 'terminal' then
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
vim.keymap.set('n', 't', function() terminal() end)
vim.keymap.set('x', 't', function() terminal() end)
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { silent = true })

-- delete selected text without copying it
vim.keymap.set('n', '<BS>', '"_d', { silent = true })
vim.keymap.set('x', '<BS>', '"_d', { silent = true })

-- Delete a line without copying it
vim.keymap.set('n', '<BS><BS>', '"_dd', { silent = true })
vim.keymap.set('x', '<BS><BS>', '"_dd', { silent = true })

-- Delete until the end of the line without copying it
vim.keymap.set('n', '<Del>', '"_D', { silent = true })
