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
---@field opt boolean
---@field build string | function
---@field url string
---@field dependencies string[]

---@class plug.Declaration
---@field [1] string
---@field branch? string
---@field as? string
---@field config? function
---@field build? string|function
---@field opt? boolean
---@field pin? boolean
---@field url? string
---@field dependencies? plug.Dependencies

local uv, iter = vim.uv, vim.iter
local command = vim.api.nvim_create_user_command

---@class plug.Config
---@field path Path?
---@field opt boolean?
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
	opt = false,
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
local Pkgs = {} -- Table of pkgs loaded from the user configuration

---@enum Status
local Status = {
	INSTALLED = 1,
	UPDATED = 2,
	REMOVED = 3,
	TO_INSTALL = 4,
	TO_RECLONE = 5,
	BUILT = 6,
	LOADED = 7
}

-- stylua: ignore
local Filter = {
	installed   = function(p) return p.status ~= Status.REMOVED and p.status ~= Status.TO_INSTALL end,
	not_removed = function(p) return p.status ~= Status.REMOVED end,
	removed     = function(p) return p.status == Status.REMOVED end,
	loaded      = function(p) return p.status == Status.LOADED end,
	built       = function(p) return p.status == Status.BUILT end,
	to_install  = function(p) return p.status == Status.TO_INSTALL end,
	to_update   = function(p) return p.status ~= Status.REMOVED and p.status ~= Status.TO_INSTALL and not p.pin end,
	to_reclone  = function(p) return p.status == Status.TO_RECLONE end,
}

---@param name string
---@param msg_op plug.Messages
---@param result string
---@param n integer?
---@param total integer?
local function report(name, msg_op, result, n, total)
	local count = n and (" [%d/%d]"):format(n, total) or ""
	vim.notify(
		(" Plug:%s %s %s"):format(count, msg_op[result], name),
		result == "err" and vim.log.levels.ERROR or vim.log.levels.INFO
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
		iter(pkg.dependencies):each(function(dep) run_build(Pkgs[dep], callback) end)
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
			local pkg = Pkgs[name]
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
				file_write(Config.log, "a+", msg)
				return
			end
			local output = ("\n%s updated:\n%s\n"):format(pkg.name, obj.stdout)
			file_write(Config.log, "a+", output)
		end
	)
end

---Object to track result of operations (installs, updates, etc.)
---@param total integer
---@param callback function?
---@return function
local function new_counter(total, callback)
	local c = { ok = 0, err = 0, nop = 0 }
	return vim.schedule_wrap(function(name, msg_op, result)
		if c.ok + c.err + c.nop < total then
			c[result] = c[result] + 1
			if result ~= "nop" or Config.verbose then
				report(name, msg_op, result, c.ok + c.nop, total)
			end
		end

		if callback and c.ok + c.err + c.nop == total then
			callback(c.ok, c.err, c.nop)
		end
	end)
end

local function lock_write()
	-- remove run key since can have a function in it, and
	-- json.encode doesn't support functions
	local pkgs = vim.deepcopy(Pkgs)
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
	Lock = Pkgs
end

local function lock_load()
	local exists, data = pcall(file_read, Config.lock)
	if exists then
		local ok, result = pcall(vim.json.decode, data)
		if ok then
			Lock = not vim.tbl_isempty(result) and result or Pkgs
			-- Repopulate 'build' key so 'vim.deep_equal' works
			for name, pkg in pairs(result) do
				pkg.build = Pkgs[name] and Pkgs[name].build or nil
			end
		end
	else
		lock_write()
		Lock = Pkgs
	end
end

---@param pkg plug.Package
local function load_plugin(pkg)
	if Filter.loaded(pkg) then return end
	if pkg.dependencies then
		iter(pkg.dependencies):each(function(dep) load_plugin(Pkgs[dep]) end)
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
---@param counter function
local function clone(pkg, counter)
	local args = vim.list_extend({ "git", "clone", pkg.url }, Config.clone_args)
	if pkg.branch then
		vim.list_extend(args, { "-b", pkg.branch })
	end
	table.insert(args, pkg.dir)
	vim.system(args, {}, function(obj)
		local ok = obj.code == 0
		if ok then
			pkg.status = Status.INSTALLED
			lock_write()
			vim.schedule(function() run_build(pkg, not pkg.opt and not Filter.loaded(pkg) and load_plugin or nil) end)
		end
		counter(pkg.name, Messages.install, ok and "ok" or "err")
	end)
end

---@param pkg plug.Package
---@param counter function
local function pull(pkg, counter)
	local prev_hash = Lock[pkg.name] and Lock[pkg.name].hash or pkg.hash
	vim.system(
		vim.list_extend({ "git", "pull" }, Config.pull_args),
		{ cwd = pkg.dir },
		function(obj)
			if obj.code ~= 0 then
				counter(pkg.name, Messages.update, "err")
				local errmsg = ("\nFailed to update %s:\n%s\n"):format(pkg.name, obj.stderr)
				file_write(Config.log, "a+", errmsg)
				return
			end
			local cur_hash = get_git_hash(pkg.dir)
			-- It can happen that the user has deleted manually a directory.
			-- Thus the pkg.hash is left blank and we need to update it.
			if cur_hash == prev_hash or prev_hash == "" then
				pkg.hash = cur_hash
				counter(pkg.name, Messages.update, "nop")
				return
			end
			log_update_changes(pkg, prev_hash, cur_hash)
			pkg.status, pkg.hash = Status.UPDATED, cur_hash
			lock_write()
			counter(pkg.name, Messages.update, "ok")
			vim.schedule(function() run_build(pkg, not pkg.opt and not Filter.loaded(pkg) and load_plugin or nil) end)
		end
	)
end

---@param pkg plug.Package
---@param counter function
local function clone_or_pull(pkg, counter)
	if Filter.to_update(pkg) then
		pull(pkg, counter)
	elseif Filter.to_install(pkg) then
		clone(pkg, counter)
	end
end

---@param pkg plug.Package
local function reclone(pkg)
	local ok = rm(pkg.dir)
	if not ok then
		return
	end
	local args = vim.list_extend({ "git", "clone", pkg.url }, Config.clone_args)
	if pkg.branch then
		vim.list_extend(args, { "-b", pkg.branch })
	end
	table.insert(args, pkg.dir)
	vim.system(args, {}, function(obj)
		if obj.code == 0 then
			pkg.status = Status.INSTALLED
			pkg.hash = get_git_hash(pkg.dir)
			lock_write()
			vim.schedule(function() run_build(pkg, not pkg.opt and not Filter.loaded(pkg) and load_plugin or nil) end)
		end
	end)
end

---@param pkg plug.Package
---@param counter function
local function resolve(pkg, counter)
	if Filter.to_reclone(pkg) then
		reclone(Pkgs[pkg.name])
	elseif Filter.to_install(pkg) then
		clone(pkg, counter)
	elseif not pkg.opt and not Filter.loaded(pkg) then
		load_plugin(pkg)
	end
end

---@param pkg string|plug.Declaration
---@return plug.Package?
local function register(pkg)
	pkg = type(pkg) == "string" and { pkg } or pkg
	if pkg.dependencies then
		vim.validate('pkg.dependencies', pkg.dependencies, vim.islist, 'a list')
	end

	local url = (pkg[1]:match("^https?://") and pkg[1])            -- [1] is a URL
		or Config.url_format:format(pkg[1])                        -- [1] is a repository name

	local name = pkg.as or vim.fs.basename(url:gsub("%.git$", "")) -- Infer name from `url`
	if not name then
		return vim.notify(" Plug: Failed to parse " .. vim.inspect(pkg), vim.log.levels.ERROR)
	end
	local opt = pkg.opt or Config.opt and pkg.opt == nil
	local dir = vim.fs.joinpath(Config.path, name)
	local ok, hash = pcall(get_git_hash, dir)

	if not Pkgs[name] then Pkgs[name] = {} end

	Pkgs[name] = {
		name = name,
		branch = pkg.branch,
		config = pkg.config,
		dependencies = pkg.dependencies and
			vim.tbl_map(function(dep) return register(dep).name end, pkg.dependencies),
		dir = dir,
		status = uv.fs_stat(dir) and Status.INSTALLED or Status.TO_INSTALL,
		hash = ok and hash or "",
		pin = pkg.pin,
		build = pkg.build,
		url = url,
		opt = opt
	}
	return Pkgs[name]
end

---@param pkg plug.Package
---@param counter function
local function remove(pkg, counter)
	local ok = rm(pkg.dir)
	counter(pkg.name, Messages.remove, ok and "ok" or "err")
	if ok then
		Pkgs[pkg.name] = { name = pkg.name, status = Status.REMOVED }
		lock_write()
	end
end

---@alias Operation
---| '"install"'
---| '"update"'
---| '"remove"'
---| '"build"'
---| '"resolve"'
---| '"sync"'

---Boilerplate around operations (autocmds, counter initialization, etc.)
---@param op Operation
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

		vim.api.nvim_exec_autocmds("User", {
			pattern = "PlugDone" .. op:gsub("^%l", string.upper),
		})
		return
	end

	local function after(ok, err, nop)
		local summary = " Plug: %s complete. %d ok; %d errors;" .. (nop > 0 and " %d no-ops" or "")
		vim.notify(string.format(summary, op, ok, err, nop))

		vim.api.nvim_exec_autocmds("User", { pattern = "PlugDone" .. op:gsub("^%l", string.upper), })

		-- This makes the logfile reload if there were changes while the job was running
		vim.cmd.checktime { args = { vim.fn.fnameescape(Config.log) }, mods = { emsg_silent = true } }
	end

	local counter = new_counter(#pkgs, after)
	iter(pkgs):each(function(pkg) fn(pkg, counter) end)
end

local function calculate_diffs()
	for name, lock_pkg in pairs(Lock) do
		local pack_pkg = Pkgs[name]
		if pack_pkg and Filter.not_removed(lock_pkg) and not vim.deep_equal(lock_pkg, pack_pkg) then
			iter { 'branch', 'url' }:each(function(k)
				if lock_pkg[k] ~= pack_pkg[k] then
					Pkgs[name].status = Status.TO_RECLONE
				end
			end)
		end
	end
end

local M = {}

---Installs all packages listed in your configuration. If a package is already
---installed, the function ignores it. If a package has a `build` argument,
---it'll be executed after the package is installed.
function M.install() exe_op("install", clone, vim.tbl_filter(Filter.to_install, Pkgs)) end

---Updates the installed packages listed in your configuration. If a package
---hasn't been installed with |PaqInstall|, the function ignores it. If a
---package had changes and it has a `build` argument, then the `build` argument
---will be executed.
---@param name string?
function M.update(name)
	exe_op("update", pull, name and { Pkgs[name] } or vim.tbl_filter(Filter.to_update, Pkgs))
end

---Removes packages found on |paq-dir| that aren't listed in your
---configuration.
function M.clean() exe_op("remove", remove, find_unlisted()) end

---Executes |paq.clean|, |paq.update|, and |paq.install|. Note that all
---paq operations are performed asynchronously, so messages might be printed
---out of order.
function M.sync()
	M.clean()
	exe_op("sync", clone_or_pull, vim.tbl_filter(Filter.not_removed, Pkgs))
end

---@param opts plug.Config
function M.setup(opts)
	Config = vim.tbl_deep_extend("force", Config, opts)
	if opts.ensure_installed then
		local pkgs = opts.ensure_installed --[[@as plug.Dependencies ]]
		vim.validate('pkgs', pkgs, vim.islist, 'a list')
		pkgs = vim.tbl_map(register, pkgs)
		lock_load()
		calculate_diffs()
		exe_op("resolve", resolve, pkgs, { silent = true })
	end
end

---Queries paq's packages storage with predefined
---filters by passing one of the following strings:
--- - "installed"
--- - "to_install"
--- - "to_update"
---@param filter string
function M.query(filter)
	vim.validate('filter', filter, 'string')
	if not Filter[filter] then
		error(string.format("No filter with name: %q", filter))
	end
	return vim.deepcopy(vim.tbl_filter(Filter[filter], Pkgs))
end

function M.list()
	local installed = vim.tbl_filter(Filter.installed, Lock)
	local removed = vim.tbl_filter(Filter.removed, Lock)
	local sort_by_name = function(t)
		table.sort(t, function(a, b) return a.name < b.name end)
	end
	sort_by_name(installed)
	sort_by_name(removed)
	local markers = { "+", "*" }
	for header, pkgs in pairs {
		["Installed packages:"] = installed,
		["Recently removed:"] = removed,
	} do
		if #pkgs ~= 0 then
			print(header)
			for _, pkg in ipairs(pkgs) do
				print(" ", markers[pkg.status] or " ", pkg.name)
			end
		end
	end
end

function M.log_open()
	vim.cmd.split(Config.log)
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
			return table.concat(vim.tbl_keys(Pkgs), '\n')
		elseif subcommand == 'build' then
			return table.concat(vim.tbl_map(function(p) return p.build and p.name or nil end, Pkgs), '\n')
		elseif subcommand == 'add' then
			return table.concat(vim.tbl_map(function(p) return not Filter.loaded(p) and p.name or nil end, Pkgs), '\n')
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
		elseif fargs[1] == 'list' then
			M.list()
		elseif fargs[1] == 'log' then
			M.log_open()
		elseif fargs[1] == 'cleanlog' then
			M.log_clean()
		elseif fargs[1] == 'sync' then
			M.sync()
		elseif fargs[1] == 'update' then
			M.update(fargs[2])
		elseif fargs[1] == 'build' then
			M.build(fargs[2])
		elseif fargs[1] == 'add' then
			load_plugin(Pkgs[fargs[2]])
		end
	end, { bar = true, nargs = '+', complete = "custom,v:lua.require'plug'.cmdline_complete" })
end

return M

-- vim: fothod=marker
