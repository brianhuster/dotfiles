local g, api, env, v = vim.g, vim.api, vim.env, vim.v
if g.loaded_nonest then
	return
end
g.loaded_nonest = true

env.EDITOR = vim.iter(v.argv):map(vim.fn.shellescape):join(' ')

if not env.NVIM then
	return
end

local _, chan = pcall(vim.fn.sockconnect, 'pipe', env.NVIM, { rpc = true })

if not chan or chan == 0 then
	io.stderr:write('Nvim failed to connect to parent')
	vim.cmd("qall!")
end

---@param cmd vim.api.keyset.cmd|string
local function send_cmd(cmd)
	if type(cmd) == 'string' then
		vim.rpcnotify(chan, 'nvim_command', cmd)
	else
		vim.rpcnotify(chan, 'nvim_cmd', cmd, {})
	end
end

api.nvim_create_autocmd('VimEnter', {
	callback = function()
		local windows = vim.iter(vim.fn.getwininfo()):filter(function(w)
			return vim.bo[w.bufnr].buftype == ''
		end):totable()

		for i, w in ipairs(windows) do
			send_cmd {
				cmd = i == 1 and 'tabedit' or 'vsplit',
				args = { vim.api.nvim_buf_get_name(w.bufnr) }
			}
			if vim.wo[w.winid].diff then
				send_cmd('diffthis')
			end
		end

		local tabpagenr = vim.rpcrequest(chan, 'nvim_call_function', 'tabpagenr', {}) --[[@as integer]]
		vim.rpcnotify(chan, 'nvim_create_autocmd', 'TabClosed', {
			command = ([[if expand("<afile>") == %s | call rpcnotify(sockconnect('pipe', '%s', #{ rpc: v:true }), 'nvim_command', 'quitall!') | endif]])
				:format(tabpagenr, v.servername),
			once = true
		})
	end,
})
