vim.cmd [[
func! Shell(cmd)
	let prev_buf = bufnr('%')
	exe 'term' a:cmd
	let cur_buf = bufnr('%')
	exe 'startinsert'
	let term_job_stop = has('nvim') ? 'call jobstop(&channel)' : 'call job_stop(term_getjob(0))'
	exe $'tmap <buffer> <Esc> <Cmd> buffer {prev_buf} <Bar> {term_job_stop} <Bar> bdelete {cur_buf} <CR>'
endf
]]

vim.api.nvim_create_user_command('Sh', function(a)
	vim.fn.Shell(a.args)
end, {
	nargs = '+',
	complete = vim.fn.executable('fish') == 1 and function(_, cmd_line, _)
		local cmd = table.concat(vim.split(cmd_line, ' '), ' ', 2)
		local results = vim.fn.systemlist { 'fish', '-c', 'complete -C' .. vim.fn.shellescape(cmd) }
		return vim.tbl_map(function(result)
			return vim.split(result, '\t')[1]
		end, results)
	end or 'shellcmdline'
})
