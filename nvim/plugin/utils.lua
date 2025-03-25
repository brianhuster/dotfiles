local api = vim.api
local command = api.nvim_create_user_command

command('GitBlameLine', function()
	print(vim.fn.system { 'git', 'blame', '-L', vim.fn.line('.') .. ',+1', api.nvim_buf_get_name(0) })
end, {})

command('Sh', function(opts)
	vim.cmd.term(opts.args)
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
