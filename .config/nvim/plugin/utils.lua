local api = vim.api
local command = api.nvim_create_user_command

command('GitDiffHead', function()
	local git_root = vim.fs.root(0, '.git')
	if not git_root then
		return vim.notify('Not a git repository', vim.log.levels.ERROR)
	end
	local path = vim.fs.relpath(git_root, api.nvim_buf_get_name(0))
	vim.cmd(([[tabedit %% | diffthis | vertical new | diffthis | read! git show HEAD^:%s]]):format(path))
end, { nargs = 0 })

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
