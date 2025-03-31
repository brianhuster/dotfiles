vim.env.EDITOR = table.concat(vim.tbl_map(function(a) return vim.fn.shellescape(a) end, vim.v.argv))

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
			vim.rpcnotify(chan, 'nvim_command', 'vsplit')
		end
		vim.rpcnotify(chan, 'nvim_exec_lua', "vim.cmd.edit(...)", { bufname })
		local parent_buf = vim.rpcrequest(chan, 'nvim_call_function', 'bufnr', { bufname })
		vim.rpcnotify(chan, 'nvim_create_autocmd', { 'WinClosed', 'BufDelete', 'BufWipeOut', 'WinLeave' }, {
			buffer = parent_buf,
			command = ([[ call rpcnotify(sockconnect('pipe', '%s', #{ rpc: v:true }), 'nvim_command', 'quitall!') ]])
				:format(vim.v.servername),
		})
	end,
})
