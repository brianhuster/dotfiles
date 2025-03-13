local M = {}

local function relpath(fname)
	return vim.fs.relpath(vim.fn.getcwd(), fname) or fname
end

if not M.symbols then
	M.symbols = {}
end

---@param opts? { include_files: string[], exclude_files: string[] }
function M.get_symbols(opts)
	local cached_file = {}
	if not opts then opts = {} end
	M.symbols = {}

	local function check_fname(fname)
		if opts.include_files then
			if not vim.tbl_contains(opts.include_files, fname) then
				return false
			end
		end
		if opts.exclude_files then
			if vim.tbl_contains(opts.exclude_files, fname) then
				return false
			end
		end
		return true
	end

	vim.lsp.buf.workspace_symbol('', { loclist = true, on_list = function(options)
		for _, item in ipairs(options.items) do
			local fname = item.filename
			if check_fname(fname) then
				local file
				if cached_file[fname] then
					file = cached_file[fname]
				else
					file = vim.fn.readfile(fname)
					cached_file[fname] = file
				end
				local content = ''
				for i = item.lnum, item.end_lnum do
					content = content .. file[i]
				end
				if not M.symbols[relpath(item.filename)] then
					M.symbols[relpath(item.filename)] = {}
				end
				table.insert(M.symbols[relpath(item.filename)], content)
			end
		end
	end})
end

function M.get_repo_map_prompt()
	local prompt = '<repo-map>\n'
	for k, v in pairs(M.symbols) do
		prompt = prompt .. ('<file name="%s">\n%s\n</file>'):format(
			vim.fn.escape(k, '"'),
			table.concat(v, '\n'))
	end
	return prompt .. '\n</repo-map>'
end

return M
