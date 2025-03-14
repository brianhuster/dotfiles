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
	api.nvim_create_autocmd('CmdlineChanged', {
		callback = function(a)
			if vim.fn.wildmenumode() == 0 and a.file == ':' and api.nvim_get_mode().mode == 'c' then
				local ok, comp = pcall(vim.fn.getcompletion, vim.fn.getcmdline(), 'cmdline')
				if not ok or #comp == 0 then return end
				api.nvim_feedkeys(vim.keycode('<Tab>'), 'nt', false)
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
