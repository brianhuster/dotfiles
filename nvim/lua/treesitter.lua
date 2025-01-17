vim.api.nvim_create_autocmd('FileType', {
	pattern = { '*' },
	callback = function(args)
		-- local ts = vim.treesitter
		-- local ft = vim.filetype.match({ filename = args.file })
		-- if ft and ts.language.get_lang(ft) then pcall(ts.start) end
		local loaded_parser = pcall(vim.treesitter.start)
		if not loaded_parser then
			vim.notify('Failed to load Treesitter parser for this buffer')
		end
	end,
})
