local M = {}

--- Search module path for matching Lua scripts.
--- @param fname string
--- @return string
function M.includeexpr(fname)
	local module = fname:gsub("%.", "/")
	local paths = vim.split(package.path, ";")
	local rtp = vim.split(vim.o.rtp, ",")
	for _, path in ipairs(rtp) do
		vim.list_extend(paths, { path .. "/lua/?.lua", path .. "/lua/?/init.lua" })
	end
	local packstart = vim.fn.globpath(vim.o.packpath, "pack/*/start/*", nil, true)
	for _, path in ipairs(packstart) do
		vim.list_extend(paths, { path .. "/lua/?.lua", path .. "/lua/?/init.lua" })
	end
	for _, template in ipairs(paths) do
		local expanded = template:gsub("?", module)
		if vim.fn.filereadable(expanded) == 1 then
			return expanded
		end
	end
end

function M.omnifunc(findstart, base)
	if findstart == 1 then
		return vim.lsp.omnifunc(findstart, base) or vim.lua_omnifunc(findstart)
	end
	local matches = vim.lsp.omnifunc(findstart, base)
	return vim.list_extend(matches, vim.lua_omnifunc(findstart, base))
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
