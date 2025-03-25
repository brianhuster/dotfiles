local api = vim.api

api.nvim_create_autocmd('InsertCharPre', {
	callback = function()
		require 'an'.ins_autocomplete('<C-x><C-f>', { '/' })
		if vim.bo.omnifunc ~= 'v:lua.vim.lsp.omnifunc' then
			require 'an'.ins_autocomplete('<C-x><C-n>', { ' ', '(', '\n' })
		end
	end
})


if api.nvim_eval('&wildmode'):match('noselect') then
	vim.api.nvim_create_autocmd('CmdlineChanged', {
		pattern = ':',
		callback = function()
			local cmdline = vim.fn.getcmdline()
			local curpos = vim.fn.getcmdpos()
			local last_char = cmdline:sub(-1)
			local _, completions = pcall(vim.fn.getcompletion, cmdline, 'cmdline')

			if
				completions and #completions > 0
				and curpos == #cmdline + 1
				and vim.fn.pumvisible() == 0
				and last_char:match('[%w%/%: ]')
				and not cmdline:match('^%d+$')
				and vim.fn.getcompletion(cmdline, 'cmdline')
			then
				vim.cmd [[ set eventignore+=CmdlineChanged ]]
				vim.api.nvim_feedkeys(vim.keycode('<Tab>'), 'nt', false)
				vim.schedule(function()
					vim.cmd [[ set eventignore-=CmdlineChanged ]]
				end)
			end
		end,
	})
	api.nvim_create_autocmd('CmdlineEnter', {
		callback = function(a)
			if vim.fn.wildmenumode() == 0 and a.file == ':' then
				api.nvim_feedkeys(vim.keycode('<Tab>'), 'nt', false)
			end
		end,
	})
end
