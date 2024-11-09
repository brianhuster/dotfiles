vim.keymap = {}
vim.keymap.set = function(mode, key, action, opts)
	if type(action) ~= "string" then
		return
	end
	vim.command(string.format('%snoremap %s %s', mode, key, action))
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
