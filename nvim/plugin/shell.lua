vim.cmd [[
func! Shell(cmd)
	let prev_buf = bufnr('%')
	let buf = nvim_create_buf(v:false, v:false)
	exe 'buffer' buf | exe "term" cmd | startinsert | normal! gg
	tmap <buffer> <Esc> <Cmd>call jobstop(&channel) <Bar> exe 'buffer' buf <Bar> exe 'bdelete' buf<CR>
endfunc
]]

vim.api.nvim_create_user_command('Sh', function(args)
	vim.fn.Shell(args.args)
end, {
	nargs = '*',
	complete = vim.fn.executable('fish') == 1 and function(arg_lead, cmd_line, cursor_pos)
		local cmd = table.concat(vim.split(cmd_line, ' '), ' ', 2)
		local results = vim.fn.systemlist { 'fish', '-c', 'complete -C' .. vim.fn.shellescape(cmd) }
		return vim.tbl_map(function(result)
			return vim.split(result, '\t')[1]
		end, results)
	end or 'shellcmdline'
})
