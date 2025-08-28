local api = vim.api

vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

api.nvim_create_autocmd('FileType', {
	callback = function()
		local ft = vim.bo.ft
		if vim.tbl_contains({ 'vim', 'editorconfig' }, ft) then
			return
		end
		pcall(function() vim.treesitter.start() end)
	end
})

vim.cmd [[
func! ExTreesitterComplete(A, L, P)
	return "start\nstop"
endf
]]

api.nvim_create_user_command("Treesitter", function(opts)
	local args = opts.args
	vim.treesitter[args]()
end, { nargs = 1, complete = "custom,ExTreesitterComplete" })
