---@alias Path string
---@alias plug.Dependencies table<string|plug.Declaration>

---@class plug.Package
---@field name string
---@field as string
---@field branch string
---@field config function
---@field dir string
---@field status Status
---@field hash string
---@field pin boolean
---@field optional boolean
---@field build string | function
---@field url string
---@field dependencies string[]
---@field condition boolean|fun():boolean

---@class plug.Declaration
---@field [1] string
---@field branch? string
---@field as? string
---@field config? function
---@field build? string|function
---@field optional? boolean
---@field pin? boolean
---@field url? string
---@field dependencies? plug.Dependencies
---@field condition? boolean|fun():boolean

local uv, iter, M = vim.uv, vim.iter, {}
local command = vim.api.nvim_create_user_command

---@class plug.Config
---@field path Path?
---@field verbose boolean?
---@field log Path?
---@field lock Path?
---@field url_format string?
---@field clone_args string[]?
---@field pull_args string[]?
---@field ensure_installed plug.Dependencies?

local Config = {
	-- stylua: ignore
	clone_args = { "--depth=1", "--recurse-submodules", "--shallow-submodules", "--no-single-branch" },
	-- Using '--tags --force' means conflicting tags will be synced with remote
	pull_args = { "--tags", "--force", "--recurse-submodules", "--update-shallow" },
	lock = vim.fs.joinpath(vim.fn.stdpath("data") --[[@as string]], "plug", "plug-lock.json"),
	log = vim.fs.joinpath(vim.fn.stdpath("log") --[[@as string]], "plug.log"),
	path = vim.fs.joinpath(vim.fn.stdpath("data") --[[@as string]], "plug"),
	url_format = 'https://%s.git',
	verbose = false,
}

---@enum plug.Messages
local Messages = {
	install = { ok = "Installed", err = "Failed to install" },
	update = { ok = "Updated", err = "Failed to update", nop = "(up-to-date)" },
	remove = { ok = "Removed", err = "Failed to remove" },
	build = { ok = "Built", err = "Failed to build" },
}

local Lock = {} -- Table of pgks loaded from the lockfile
M.Pkgs = {} -- Table of pkgs loaded from the user configuration

---@enum Status
local Status = {
	INSTALLED = 'installed',
	UPDATED = 'updated',
	REMOVED = 'removed',
	TO_INSTALL = 'to install',
	TO_RECLONE = 'to reclone',
	BUILT = 'built',
	LOADED = 'loaded',
}

-- stylua: ignore
local Filter = {
	installed   = function(p) return p.status ~= Status.REMOVED and p.status ~= Status.TO_INSTALL end,
	not_removed = function(p) return p.status ~= Status.REMOVED end,
	removed     = function(p) return p.status == Status.REMOVED end,
	loaded      = function(p) return p.status == Status.LOADED end,
	built       = function(p) return p.status == Status.BUILT or p.status == Status.LOADED end,
	to_install  = function(p) return p.status == Status.TO_INSTALL end,
	to_update   = function(p) return p.status ~= Status.REMOVED and p.status ~= Status.TO_INSTALL and not p.pin end,
	to_reclone  = function(p) return p.status == Status.TO_RECLONE end,
}

---@param name string
---@param msg_op plug.Messages
---@param result 'ok'|'err'|'nop'
local function report(name, msg_op, result)
	vim.notify(
		("Plug: %s %s"):format(msg_op[result], name, vim.log.levels[result == 'err' and 'ERROR' or 'INFO'])
	)
end

---@param path string
---@param flags string
---@param data string
local function file_write(path, flags, data)
	local err_msg = "Failed to %s '" .. path .. "'"
	local file = assert(uv.fs_open(path, flags, 0x1A4), err_msg:format("open"))
	assert(uv.fs_write(file, data), err_msg:format("write"))
	assert(uv.fs_close(file), err_msg:format("close"))
end

---@param path string
---@return string
local function file_read(path)
	return table.concat(vim.fn.readfile(path), "\n")
end

---@param pkg plug.Package
---@param callback fun(pkg: plug.Package)?
local function run_build(pkg, callback)
	if Filter.built(pkg) then return end
	if pkg.dependencies then
		iter(pkg.dependencies):each(function(dep) run_build(M.Pkgs[dep], callback) end)
	end
	local t, ok = type(pkg.build), false
	if t == "function" then
		ok = pcall(pkg.build --[[@as function]])
		report(pkg.name, Messages.build, ok and "ok" or "err")
	elseif t == "string" and pkg.build:sub(1, 1) == ":" then
		ok = pcall(vim.cmd --[[@as function]], pkg.build)
		report(pkg.name, Messages.build, ok and "ok" or "err")
	elseif t == "string" then
		vim.system(
			{ vim.o.shell, vim.o.shellcmdflag, pkg.build --[[@as string]] },
			{ cwd = pkg.dir },
			vim.schedule_wrap(function(obj) report(pkg.name, Messages.build, obj.code == 0 and "ok" or "err") end))
	end
	vim.cmd.helptags { args = { vim.fs.joinpath(pkg.dir, "doc") }, mods = { emsg_silent = true } }
	if ok then pkg.status = Status.BUILT end
	if callback then callback(pkg) end
end

---@return plug.Package
local function find_unlisted()
	local unlisted = {}
	local path = Config.path
	for name, type in vim.fs.dir(path) do
		if type == "directory" and name ~= "paq-nvim" then
			local dir = vim.fs.joinpath(path, name)
			local pkg = M.Pkgs[name]
			if not pkg or pkg.dir ~= dir then
				table.insert(unlisted, { name = name, dir = dir })
			end
		end
	end
	return unlisted
end

---@param dir Path
---@return string
local function get_git_hash(dir)
	local first_line = function(path)
		local data = file_read(path)
		return vim.split(data, "\n")[1]
	end
	local head_ref = first_line(vim.fs.joinpath(dir, ".git", "HEAD"))
	return head_ref and first_line(vim.fs.joinpath(dir, ".git", head_ref:sub(6, -1)))
end

---Remove files or directories
---@param path Path Path to remove
---@return boolean
local function rm(path)
	local recursive = vim.fn.isdirectory(path) == 1 and true or nil
	if vim.fn.has('nvim-0.11') == 1 then
		return pcall(vim.fs.rm, path, { recursive = recursive })
	end
	return vim.fn.delete(path, recursive and "rf" or nil) == 0
end

---@param data string
local function write_log(data)
	file_write(Config.log, "a+", ('%s %s'):format(os.date("%Y-%m-%d %H:%M:%S"), data))
end

---@param pkg plug.Package
---@param prev_hash string
---@param cur_hash string
local function log_update_changes(pkg, prev_hash, cur_hash)
	vim.system(
		{ "git", "log", "--pretty=format:* %s", ("%s..%s"):format(prev_hash, cur_hash) },
		{ cwd = pkg.dir, text = true },
		function(obj)
			if obj.code ~= 0 then
				local msg = ("\nFailed to execute git log into %q (code %d):\n%s\n"):format(
					pkg.dir,
					obj.code,
					obj.stderr
				)
				write_log(msg)
				return
			end
			local output = ("\n%s updated:\n%s\n"):format(pkg.name, obj.stdout)
			write_log(output)
		end
	)
end

local function lock_write()
	-- remove run key since can have a function in it, and
	-- json.encode doesn't support functions
	local pkgs = vim.deepcopy(M.Pkgs)
	for p, _ in pairs(pkgs) do
		pkgs[p].build = nil
		pkgs[p].config = nil
	end
	local ok, result = pcall(vim.json.encode, pkgs)
	if not ok then
		error(vim.inspect(result))
	end
	-- Ignore if fail
	pcall(file_write, Config.lock, "w", result)
	Lock = M.Pkgs
end

local function lock_load()
	local exists, data = pcall(file_read, Config.lock)
	if exists then
		local ok, result = pcall(vim.json.decode, data)
		if ok then
			Lock = not vim.tbl_isempty(result) and result or M.Pkgs
			-- Repopulate 'build' key so 'vim.deep_equal' works
			for name, pkg in pairs(result) do
				pkg.build = M.Pkgs[name] and M.Pkgs[name].build or nil
			end
		end
	else
		lock_write()
		Lock = M.Pkgs
	end
end

---@param pkg plug.Package
local function load_plugin(pkg)
	if pkg.name == 'img-clip.nvim' then
		debug.debug()
	end
	if Filter.loaded(pkg) then return end
	if pkg.dependencies then
		iter(pkg.dependencies):each(function(dep) load_plugin(M.Pkgs[dep]) end)
	end
	vim.opt.rtp:prepend(pkg.dir)
	if pkg.config then pkg.config() end
	if not vim.v.vim_did_enter then return end
	for _, file in ipairs(vim.fn.glob(vim.fs.joinpath(pkg.dir, "plugin/**/*.{vim,lua}"), true, true)) do
		vim.cmd.source(file)
	end
	pkg.status = Status.LOADED
end

---@param pkg plug.Package
---@param callback fun(plug.Package)?
local function clone(pkg, callback)
	local args = vim.list_extend({ "git", "clone", pkg.url }, Config.clone_args)
	if pkg.branch then
		vim.list_extend(args, { "-b", pkg.branch })
	end
	table.insert(args, pkg.dir)
	vim.system(args, {}, function(obj)
		local ok = obj.code == 0
		if ok then
			pkg.status = Status.INSTALLED
			pkg.hash = get_git_hash(pkg.dir)
			lock_write()
			vim.schedule(function() run_build(pkg, callback) end)
		end
	end)
end

---@param pkg plug.Package
local function pull(pkg)
	local prev_hash = Lock[pkg.name] and Lock[pkg.name].hash or pkg.hash
	vim.system(
		vim.list_extend({ "git", "pull" }, Config.pull_args),
		{ cwd = pkg.dir },
		function(obj)
			if obj.code ~= 0 then
				report(pkg.name, Messages.update, 'err')
				local errmsg = ("\nFailed to update %s:\n%s\n"):format(pkg.name, obj.stderr)
				write_log(errmsg)
				return
			end
			local cur_hash = get_git_hash(pkg.dir)
			-- It can happen that the user has deleted manually a directory.
			-- Thus the pkg.hash is left blank and we need to update it.
			if cur_hash == prev_hash or prev_hash == "" then
				pkg.hash = cur_hash
				report(pkg.name, Messages.update, 'nop')
				return
			end
			log_update_changes(pkg, prev_hash, cur_hash)
			pkg.status, pkg.hash = Status.UPDATED, cur_hash
			lock_write()
			report(pkg.name, Messages.update, 'ok')
			vim.schedule(function() run_build(pkg) end)
		end
	)
end

---@param pkg plug.Package
local function resolve(pkg, noload)
	local to_load = not noload and not pkg.optional
	if pkg.dependencies then
		iter(pkg.dependencies):each(function(dep) resolve(M.Pkgs[dep], pkg.optional) end)
	end
	if Filter.to_reclone(pkg) then
		if rm(pkg.dir) then clone(pkg, to_load and load_plugin or nil) end
	elseif Filter.to_install(pkg) then
		clone(pkg, to_load and to_load or nil)
	else
		if to_load then load_plugin(pkg) end
	end
end

---@param pkg string|plug.Declaration
---@return plug.Package|{}
local function register(pkg)
	pkg = type(pkg) == "string" and { pkg } or pkg
	local check = pkg.condition == nil and true or pkg.condition
	check = type(check) == "function" and check() or check
	if not check then return {} end

	if pkg.dependencies then
		vim.validate('pkg.dependencies', pkg.dependencies, vim.islist, 'a list')
	end

	local url = (pkg[1]:match("^https?://") and pkg[1])            -- [1] is a URL
		or Config.url_format:format(pkg[1])                        -- [1] is a repository name

	local name = pkg.as or vim.fs.basename(url:gsub("%.git$", "")) -- Infer name from `url`
	if not name then
		vim.notify(" Plug: Failed to parse " .. vim.inspect(pkg), vim.log.levels.ERROR)
		return {}
	end
	local dir = vim.fs.joinpath(Config.path, name)
	local ok, hash = pcall(get_git_hash, dir)

	if not M.Pkgs[name] then M.Pkgs[name] = {} end

	if M.Pkgs[name].branch and pkg.branch ~= M.Pkgs[name].branch then
		vim.notify(('Conflicting branch of package %s (%s vs %s)'):format(name, M.Pkgs[name].branch, pkg.branch),
			vim.log.levels.ERROR)
		return {}
	end

	M.Pkgs[name] = {
		name = name,
		branch = pkg.branch,
		config = pkg.config,
		dependencies = pkg.dependencies and
			vim.tbl_map(function(d) return register(d).name or nil end, pkg.dependencies) or nil,
		dir = dir,
		status = uv.fs_stat(dir) and Status.INSTALLED or Status.TO_INSTALL,
		hash = ok and hash or "",
		pin = pkg.pin,
		build = pkg.build,
		url = url,
		optional = pkg.optional
	}
	return M.Pkgs[name]
end

---@param pkg plug.Package
local function remove(pkg)
	local ok = rm(pkg.dir)
	report(pkg.name, Messages.remove, ok and 'ok' or 'err')
	if ok then
		M.Pkgs[pkg.name] = { name = pkg.name, status = Status.REMOVED }
		lock_write()
	end
end

---@alias plug.Operation 'install'|'update'|'remove'|'resolve'

---Boilerplate around operations (autocmds, counter initialization, etc.)
---@param op plug.Operation
---@param fn function
---@param pkgs plug.Package[]
---@param opts? { silent: boolean? }
local function exe_op(op, fn, pkgs, opts)
	opts = opts or {}
	local silent = opts.silent or false
	if vim.tbl_isempty(pkgs) then
		if not silent then
			vim.notify(" Plug: Nothing to " .. op)
		end
		return
	end

	iter(pkgs):each(function(pkg) fn(pkg) end)
end

local function calculate_diffs()
	for name, lock_pkg in pairs(Lock) do
		local pack_pkg = M.Pkgs[name]
		if pack_pkg and Filter.not_removed(lock_pkg) and not vim.deep_equal(lock_pkg, pack_pkg) then
			iter { 'branch', 'url' }:each(function(k)
				if lock_pkg[k] ~= pack_pkg[k] then
					M.Pkgs[name].status = Status.TO_RECLONE
				end
			end)
		end
	end
end

---Installs all packages listed in your configuration. If a package is already
---installed, the function ignores it. If a package has a `build` argument,
---it'll be executed after the package is installed.
function M.install() exe_op("install", clone, vim.tbl_filter(Filter.to_install, M.Pkgs)) end

---Updates the installed packages listed in your configuration. If a package
---hasn't been installed with |PaqInstall|, the function ignores it. If a
---package had changes and it has a `build` argument, then the `build` argument
---will be executed.
---@param name string?
function M.update(name)
	if not name then
		exe_op("update", pull, vim.tbl_filter(Filter.to_update, M.Pkgs))
	else
		local deps = M.Pkgs[name].dependencies
		if deps then
			iter(deps):each(function(d) M.update(d[name]) end)
		end
		pull(M.Pkgs[name])
	end
end

---Removes packages found on |paq-dir| that aren't listed in your
---configuration.
function M.clean() exe_op("remove", remove, find_unlisted()) end

---@param opts plug.Config
function M.setup(opts)
	Config = vim.tbl_deep_extend("force", Config, opts)
	if opts.ensure_installed then
		local pkgs = opts.ensure_installed --[[@as plug.Dependencies ]]
		vim.validate('pkgs', pkgs, vim.islist, 'a list')
		pkgs = vim.tbl_map(register, pkgs)
		lock_load()
		calculate_diffs()
		exe_op("resolve", resolve, pkgs)
	end
end

function M.log_open()
	vim.cmd.split(Config.log)
	vim.bo.autoread = true
	vim.cmd("silent! normal! Gzz")
end

function M.log_clean()
	return assert(uv.fs_unlink(Config.log)) and vim.notify(" Plug: log file deleted")
end

---@param L string
---@return string
function M.cmdline_complete(_, L, _)
	local subcommands = { 'install', 'clean', 'list', 'log', 'cleanlog', 'sync', 'update', 'build', 'add' }
	local subcommand = vim.split(L, ' ')[2]
	if not vim.split(L, ' ')[3] then
		return table.concat(subcommands, '\n')
	else
		if subcommand == 'update' then
			return table.concat(vim.tbl_keys(M.Pkgs), '\n')
		elseif subcommand == 'build' then
			return table.concat(vim.tbl_map(function(p) return p.build and p.name or nil end, M.Pkgs), '\n')
		elseif subcommand == 'add' then
			return table.concat(vim.tbl_map(function(p) return not Filter.loaded(p) and p.name or nil end, M.Pkgs), '\n')
		else
			return ''
		end
	end
end

if not _G.loaded_plug then
	_G.loaded_plug = true
	command("Plug", function(cmd)
		local fargs = cmd.fargs
		if fargs[1] == 'install' then
			M.install()
		elseif fargs[1] == 'clean' then
			M.clean()
		elseif fargs[1] == 'log' then
			M.log_open()
		elseif fargs[1] == 'cleanlog' then
			M.log_clean()
		elseif fargs[1] == 'update' then
			M.update(fargs[2])
		elseif fargs[1] == 'build' then
			M.build(fargs[2])
		elseif fargs[1] == 'add' then
			load_plugin(M.Pkgs[fargs[2]])
		end
	end, { bar = true, nargs = '+', complete = "custom,v:lua.require'plug'.cmdline_complete" })
end

return M

-- vim: fothod=marker
