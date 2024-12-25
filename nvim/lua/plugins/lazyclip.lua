return {
	{
		"atiladefreitas/lazyclip",
		config = function()
			vim.cmd([[nnoremap <silent> <leader>cb :lua require('lazyclip').show_clipboard()<CR>]])
		end,
	},
}
