vim.api.nvim_create_autocmd('FileType', {
	pattern = { '*' },
	callback = function(args)
		local ts = vim.treesitter
		local ft = vim.filetype.match({ filename = args.file })
		if ft and ts.language.get_lang(ft) then ts.start() end
	end,
})
