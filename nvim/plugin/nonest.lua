vim.env.EDITOR = vim.v.progpath

if not vim.env.NVIM then
	return
end

local api = vim.api
local address = vim.env.NVIM

local _, chan = pcall(vim.fn.sockconnect, 'pipe', address, { rpc = true })

if not chan or chan == 0 then
	vim.notify('Failed to connect to parent', vim.log.levels.ERROR)
	vim.cmd('quitall!')
end

api.nvim_create_autocmd('VimEnter', {
	callback = function()
		local bufname = api.nvim_buf_get_name(0)
		local wins_num = vim.rpcrequest(chan, 'nvim_eval', 'len(nvim_list_wins())')
		if wins_num == 1 then
			vim.rpcrequest(chan, 'nvim_command', 'vsplit')
		end
		vim.rpcrequest(chan, 'nvim_exec_lua', "vim.cmd.edit(...)", { bufname })
		local parent_buf = vim.rpcrequest(chan, 'nvim_call_function', 'bufnr', { bufname })
		vim.rpcrequest(chan, 'nvim_create_autocmd', { 'WinClosed', 'BufDelete', 'BufWipeOut', 'WinLeave' }, {
			buffer = parent_buf,
			command = ([[ silent! call rpcnotify(sockconnect('pipe', '%s', #{ rpc: v:true }), 'nvim_command', 'quitall!') ]]):format(vim.v.servername),
		})
	end,
})
