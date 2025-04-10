vim.bo.makeprg = ':JsonParse'
vim.bo.formatexpr = "v:lua.require'an.json'.formatexpr()"

vim.api.nvim_buf_create_user_command(0, 'JsonParse', function()
	vim.print(vim.fn.json_decode(vim.api.nvim_buf_get_lines(0, 0, -1, false)))
end, {})

vim.b.undo_ftplugin = table.concat {
	vim.b.undo_ftplugin or '',
	'setl makeprg< formatexpr<',
	'delcommand -buffer JsonParse',
}
