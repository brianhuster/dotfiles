local vim = vim
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

command("RestartSession", function()
	vim.cmd("mksession!")
	vim.cmd.restart(("source %s | call delete(v:this_session)"):format(vim.fn.fnameescape(vim.fs.abspath("Session.vim"))))
end, { nargs = 0, desc = "Restart nvim and restore session" })

command("CopyLua", function(opts)
    local expr = opts.args
    local result = load("return " .. expr)()
	local convert_func = type(result) == "table" and vim.inspect or tostring
	vim.fn.setreg("+", convert_func(result))
end, { nargs = 1, desc = "Copy result of a Lua expression to clipboard", complete = "lua" })
