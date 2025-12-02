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

command("Translate", function(opts)
	require'an.translate'.translate_cmd(opts) end,
	{
		nargs = "*",
		range = true,
		complete = "custom,v:lua.require'an.translate'.translate_complete"
	}
)
