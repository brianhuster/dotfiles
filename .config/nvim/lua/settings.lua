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

vim.o.mouse = 'a'
vim.o.number = true
vim.o.expandtab = false
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.cursorline = false
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.history = 5000
vim.o.clipboard = 'unnamedplus'
vim.o.autowriteall = true
vim.o.modeline = false
vim.g.mapleader = ' '
if vim.fn.has('nvim') == 1 then
	vim.filetype.add({
		pattern = {
			['.*%.ejs'] = 'html',
			['.*/doc/.+%.txt'] = 'help'
		}
	})
end
