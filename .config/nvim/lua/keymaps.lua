local map = vim.keymap.set

local function terminal()
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
map('n', 't', function() terminal() end)
map('x', 't', function() terminal() end)
map('t', '<Esc>', '<C-\\><C-n>', { silent = true })

-- delete selected text without copying it
map('n', '<BS>', '"_d', { silent = true })
map('x', '<BS>', '"_d', { silent = true })

-- Delete a line without copying it
map('n', '<BS><BS>', '"_dd', { silent = true })
map('x', '<BS><BS>', '"_dd', { silent = true })

-- Delete until the end of the line without copying it
map('n', '<Del>', '"_D', { silent = true })
