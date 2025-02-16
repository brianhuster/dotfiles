local M = {}

---@source https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/lua_ls.lua
---@param fname string
---@return string
function M.find_root(fname)
	local root_markers = {
		'.luarc.json',
		'.luarc.jsonc',
		'.luacheckrc',
		'.stylua.toml',
		'stylua.toml',
		'selene.toml',
		'selene.yml',
	}
	local root = vim.fs.root(fname, root_markers)
	if root and root ~= vim.env.HOME then
		return root
	end
	local root_lua = vim.fs.root(fname, 'lua') or ''
	local root_git = vim.fs.root(fname, '.git') or ''
	if #root_lua == 0 and #root_git == 0 then
		return '.'
	end
	return #root_lua >= #root_git and root_lua or root_git
end


--- Search module path for matching Lua scripts.
--- @param fname string
--- @return string
function M.includeexpr(fname)
	local sep = package.config:sub(1, 1)

	---@param prefix string
	---@return string[]
	local function templates(prefix)
		local dir = prefix .. sep .. "lua" .. sep
		return { dir .. "?.lua", dir .. "?" .. sep .. "init.lua" }
	end

	local paths = templates(vim.b.root_dir or '.')
	local module = fname:gsub("%.", "/")
	local rtp = vim.split(vim.o.rtp, ",")
	for _, path in ipairs(rtp) do
		vim.list_extend(paths, templates(path))
	end
	local packstart = vim.fn.globpath(vim.o.packpath, "pack/*/start/*", nil, true)
	for _, path in ipairs(packstart) do
		vim.list_extend(paths, templates(path))
	end
	vim.list_extend(paths, vim.split(package.path, ";"))
	for _, template in ipairs(paths) do
		local expanded = template:gsub("?", module)
		if vim.fn.filereadable(expanded) == 1 then
			return expanded
		end
	end
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

function M.keywordexpr()
	local temp_isk = vim.o.iskeyword
	vim.cmd("set iskeyword+=.")
	local _, cword = pcall(vim.fn.expand, "<cword>")
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

return M
