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

---@param cmd string
local function send_cmd(cmd)
	vim.rpcnotify(chan, 'nvim_command', cmd)
end

---@type string[]
local commands = {}

---@param winid integer
---@param cmd string
---@param mod? string
local function add_cmd_for_win(winid, cmd, mod)
	table.insert(
		commands,
		('%s %s %s'):format(
			mod, cmd,
			vim.fn.fnameescape(api.nvim_buf_get_name(api.nvim_win_get_buf(winid)))))
	if vim.wo[winid].diff then
		table.insert(commands, "diffthis")
	end
end

---@param layout vim.fn.winlayout.ret
---@param is_first boolean
local function process_winlayout(layout, is_first)
	local type = layout[1]

	---@param data vim.fn.winlayout.ret[]
	---@param split_type "vsplit"|"split"
	---@param first boolean
	local function process_splits(data, split_type, first)
		process_winlayout(data[1], first)

		for i = 2, #data do
			local winid = nil
			if data[i][1] == 'leaf' then
				winid = data[i][2]
			end

			local position = i == #data and "botright" or "belowright"

			add_cmd_for_win(winid --[[@as integer]], split_type, position)

			if data[i][1] ~= 'leaf' then
				process_winlayout(data[i], false)
			end
		end
	end

	if type == 'leaf' then
		local winid = layout[2]
		if is_first then
			add_cmd_for_win(winid --[[@as integer]], "edit")
		end
	elseif type == 'col' then
		process_splits(layout[2] --[[@as vim.fn.winlayout.ret[] ]], "split", is_first)
	elseif type == 'row' then
		process_splits(layout[2] --[[@as vim.fn.winlayout.ret[] ]], "vsplit", is_first)
	end
end

api.nvim_create_autocmd('VimEnter', {
	callback = function()
		local winlayout = vim.fn.winlayout()
		process_winlayout(winlayout, true)

		send_cmd('tabnew')
		vim.iter(commands):each(send_cmd)

		local tabpagenr = vim.rpcrequest(chan, 'nvim_call_function', 'tabpagenr', {}) --[[@as integer]]
		vim.rpcnotify(chan, 'nvim_create_autocmd', 'TabClosed', {
			command = ([[if expand("<afile>") == %s | call rpcnotify(sockconnect('pipe', '%s', #{ rpc: v:true }), 'nvim_command', 'quitall!') | endif]])
				:format(tabpagenr, v.servername),
			once = true
		})
	end,
})
