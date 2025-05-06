local M = {}

local api = vim.api

---@param fname string
---@return string
function M.find_root(fname)
	return vim.fs.root(fname, 'lua') or vim.fn.getcwd()
end

--- @param module string
---@return string
function M.includeexpr(module)
	module = module:gsub('%.', '/')

	local root = vim.fs.root(vim.api.nvim_buf_get_name(0), 'lua') or vim.fn.getcwd()
	for _, fname in ipairs { module, vim.fs.joinpath(root, 'lua', module) } do
		for _, suf in ipairs { '.lua', '/init.lua' } do
			local path = fname .. suf
			if vim.uv.fs_stat(path) then
				return path
			end
		end
	end

	local modInfo = vim.loader.find(module)[1]
	return modInfo and modInfo.modpath or module
end

---@param keyword string
---@param opts {prefix: string?, suffix: string?, regex: string?, pattern: string?, on_keyword: function?}
local function lookup_help(keyword, opts)
	if opts.regex and opts.pattern then
		error("Cannot use both regex and pattern options", vim.log.levels.ERROR)
		return
	end
	if opts.regex then
		local match_start, match_end = vim.regex(opts.regex):match_str(keyword)
		if not match_start then
			return
		end
		keyword = keyword:sub(match_start + 1, match_end)
	elseif opts.pattern then
		keyword = keyword:match(opts.pattern)
	elseif opts.on_keyword then
		keyword = opts.on_keyword(keyword)
	end
	if keyword and keyword ~= "" then
		if opts.prefix then
			keyword = opts.prefix .. keyword
		end
		if opts.suffix then
			keyword = keyword .. opts.suffix
		end
		return pcall(vim.cmd.help, vim.fn.escape(keyword, " []*?"))
	end
end

function M.keywordprg()
	local temp_isk = vim.o.iskeyword
	vim.cmd("set iskeyword+=.,#")
	---@type _, string
	local _, cword = pcall(vim.fn.expand, "<cword>") ---@diagnostic disable-line: assign-type-mismatch
	vim.o.iskeyword = temp_isk
	if not cword or #cword == 0 then return end
	local list_of_opts = {
		-- Nvim API
		{ regex = [[nvim_.\+]],                                                         suffix = '()' },
		-- Vimscript functions
		{ regex = [[\(vim\.fn\.\)\@<=\w\+]],                                            suffix = '()' },
		-- Options
		{ regex = [[\(vim\.\(o\|go\|bo\|wo\|opt\|opt_local\|opt_global\)\.\)\@<=\w\+]], prefix = "'", suffix = "'" },
		-- Vimscript variables
		{
			---@param keyword string
			---@return string?
			on_keyword = function(keyword)
				local match_start, match_end = vim.regex([[\(vim\.\(g\|b\|w\|v\|t\)\.\)\@<=\w\+]]):match_str(keyword)
				if not match_start then return end
				return keyword:sub(match_start - 1, match_start - 1) .. ':' .. keyword:sub(match_start + 1, match_end)
			end
		},
		-- Ex commands
		{ regex = [[\(vim\.cmd\.\)\@<=\w\+]], prefix = ":" },
		-- Luv
		{ regex = [[\(vim\.uv\.\)\@<=\w\+]],  suffix = '()' },
		-- Luaref
		{ prefix = 'lua-' },
		-- environment variable
		{ regex = [[\(vim\.env\.\)\@<=\w\+]], prefix = "$" },
		-- Other
		{}
	}
	local success
	for _, opts in ipairs(list_of_opts) do
		success = lookup_help(cword, opts)
		if success then
			break
		end
	end
	if not success then
		vim.notify("Sorry, can't find relevant help for " .. cword, vim.log.levels.ERROR)
	end
end

--- @see https://github.com/lewis6991/dotfiles
--- @param x string
--- @return string?
local function match_require(x)
	return x:match('require')
		and (
			x:match("require%s*%(%s*'([^.']+).*'%)") -- require('<module>')
			or x:match('require%s*%(%s*"([^."]+).*"%)') -- require("<module>")
			or x:match("require%s*'([^.']+).*'%)")  -- require '<module>'
			or x:match('require%s*"([^."]+).*"%)')  -- require "<module>"
			or x:match("pcall(require,%s*'([^.']+).*'%)") -- pcall(require, "<module>")
			or x:match('pcall(require,%s*"([^."]+).*"%)') -- pcall(require, "<module>")
		)
end

--- @param client vim.lsp.Client
--- @param bufnr integer
function M.auto_require(client, bufnr)
	local local_ws = nil
	if client.workspace_folders then
		local path = client.workspace_folders[1].name
		local_ws = vim.fs.joinpath(path, 'lua')
		if vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc') then
			-- Updates to settings are ignored if a .luarc.json is present
			return
		end
	end

	client.settings = vim.tbl_deep_extend('keep', client.settings, {
		Lua = { workspace = { library = {} } },
	})

	--- @param first? number
	--- @param last? number
	local function on_lines(_, _, _, first, _, last)
		local did_change = false

		local lines = api.nvim_buf_get_lines(bufnr, first or 0, last or -1, false)
		for _, line in ipairs(lines) do
			local m = match_require(line)
			if m then
				for _, mod in ipairs(vim.loader.find(m, { patterns = { '', '.lua' } })) do
					local lib = vim.fs.dirname(mod.modpath)
					local libs = client.settings.Lua.workspace.library
					if not lib == local_ws and not vim.tbl_contains(libs, lib) then
						libs[#libs + 1] = lib
						did_change = true
					end
				end
			end
		end

		if did_change then
			client:notify('workspace/didChangeConfiguration', { settings = client.settings })
		end
	end

	api.nvim_buf_attach(bufnr, false, {
		on_lines = on_lines,
		on_reload = on_lines,
	})

	-- Initial scan
	on_lines()
end

return M
