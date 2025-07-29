local g, api, env, v = vim.g, vim.api, vim.env, vim.v
if g.loaded_nonest then
	return
end
g.loaded_nonest = true

env.EDITOR = vim.iter(v.argv):map(vim.fn.shellescape):join(' ')

if not env.NVIM then
	return
end

local diffmode = false
local filenames = {} ---@type string[]
local args = { unpack(v.argv, 2) } ---@type string[]

do
	local i = 1
	local always_filename_args = false

	while i <= #args do
		local a = args[i]
		if always_filename_args then
			vim.list_extend(filenames, { unpack(args, i) })
			break
		end

		local handled = false
		-- Skip all flags that run arbitrary commands
		if a == '-c' or a == '--cmd' or a == '-S' then
			i = i + 1
		else
			if a == '--' then
				always_filename_args = true
			elseif a == '-d' then
				diffmode = true
			elseif a:sub(1, 1) ~= '-' and a:sub(1, 1) ~= '+' then
				table.insert(filenames, a)
			end
		end
		i = i + 1
	end
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
		send_cmd { cmd = 'tabedit', args = { filenames[1] } }
		if diffmode then
			send_cmd('diffthis')
		end

		for i = 2, #filenames do
			send_cmd { cmd = 'vsplit', args = { filenames[i] } }
			if diffmode then
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
