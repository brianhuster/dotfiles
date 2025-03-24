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
		local bufs = api.nvim_list_bufs()
		for i, buf in ipairs(bufs) do
			if not api.nvim_buf_is_loaded(buf) then
				return
			end
			vim.rpcnotify(chan, 'nvim_command', (i == 1 and '' or 'vsplit | ') .. 'edit ' .. api.nvim_buf_get_name(buf))
		end
		vim.fn.chanclose(chan)
		vim.cmd 'quitall!'
	end,
})
