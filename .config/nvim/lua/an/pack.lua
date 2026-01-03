local M = {}

---@alias an.pack.build function|string[]

---@class an.pack.Spec: vim.pack.Spec
---@field build? an.pack.build

---@type table<string, { build: an.pack.build }>
M.pkgs = {}

---@param func function
---@param ... any
M.exec = function(func, ...)
	local ok, msg = pcall(func, ...)
	if not ok then
		vim.notify(debug.traceback(msg), vim.log.levels.ERROR)
	end
end

---@param pkgs (string|an.pack.Spec)[]
function M.add(pkgs)
	for _, pkg in ipairs(pkgs) do
		if type(pkg) == 'table' and pkg.build then
			M.pkgs[pkg.src] = { build = pkg.build }
		end
	end
	M.exec(vim.pack.add, pkgs)
end

---@param action an.pack.build
---@param data { kind: 'install'|'update'|'delete', spec: vim.pack.Spec, path: string }
local function build(action, data)
	local t = type(action)
	if t == 'function' then
		M.exec(action)
	else
        vim.system(action,
			{ cwd = data.path },
			vim.schedule_wrap(function(obj)
				vim.notify(obj.stdout)
				vim.notify(obj.stderr, vim.log.levels.ERROR)
			end)
		)
	end
end

vim.api.nvim_create_autocmd('PackChanged', {
	callback = function(args)
		local data = args.data
		if not (data.kind == 'install' or data.kind == 'update') then
			return
		end
		local build_spec = M.pkgs[data.spec.src] and M.pkgs[data.spec.src].build
		if build_spec then
			build(build_spec, data)
		end
	end
})

local command = vim.api.nvim_create_user_command

---@return string
M.PackUpdate_compl = function()
	local dir = vim.fn.stdpath('data')..'/site/pack/core/opt'
	return vim.iter(vim.fn.readdir(dir)):map(function(n)
		return vim.fn.fnameescape(n)
	end):join('\n')
end

M.PackDel_compl = M.PackUpdate_compl

command('PackUpdate', function(args)
	local names, bang = args.fargs, args.bang
	vim.pack.update(names[1] and names or nil,
		{ force = bang })
end, {
	bang = true,
	nargs = '?',
	complete = "custom,v:lua.require'an.pack'.PackUpdate_compl"
})

command('PackDel', function(args)
	local names = args.fargs
	vim.pack.del(names, { force = args.bang })
end, { nargs = 1, complete = "custom,v:lua.require'an.pack'.PackDel_compl", bang = true })

command('PackClean', function(opts)
	local plugins = vim.iter(vim.pack.get(nil, { info = false })):filter(
	---@param pkg vim.pack.PlugData
		function(pkg)
			return not pkg.active
		end):map(
	---@param pkg vim.pack.PlugData
		function(pkg)
			return pkg.spec.name
        end):totable()
	for _, name in ipairs(plugins) do
		vim.pack.del({ name }, { force = opts.bang })
	end
end, { desc = 'Clean unused packages' })
return M
