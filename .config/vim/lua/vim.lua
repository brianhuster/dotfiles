vim.keymap = {}
vim.keymap.set = function(mode, key, action, opts)
	if type(action) ~= "string" then
		return
	end
	vim.command(('%s%smap %s %s %s'):format(
		mode,
		opts.noremap and nore or "",
		opts.silent and "<silent>" or "",
		key,
		action))
end

if not vim.o then
	--- Credit : SongTianxiang
	vim.o = setmetatable({}, {
		__index = function(_, k)
			local ok, optv = pcall(vim.eval, "&" .. k) -- notice this like
			if not ok then
				return error("Unknown option " .. k)
			end
			return optv
		end,
		__newindex = function(o, k, v)
			local _ = vim.o[k]
			if type(v) == "boolean" then
				k = v and k or "no" .. k
				vim.command('set ' .. k)
				return
			end
			vim.command('set ' .. k .. '=' .. v)
		end,
	})
end

vim.inspect = function(any)
	if vim.type(any) == 'table' then
		return vim.fn.execute("echo luaeval('vim.dict(any)')")
	end
	if vim.type(any) == 'list' or vim.type(any) == 'dict' then
		return vim.fn.execute("echo luaeval('any')")
	end
	return any
end

vim.print = function(any)
	print(vim.inspect(any))
end

vim.trim = vim.fn.trim
vim.system = function(cmdtbl)
	local cmd = table.concat(cmdtbl, " ")
	return vim.fn.system(cmd)
end
