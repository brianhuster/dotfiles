return {
	'justinmk/vim-dirvish',
	config = function()
		vim.g.dirvish_mode = ':sort ,^.*[\\/],'
		-- vim.fn['dirvish#add_icon_fn'](function(p)
		-- 	return p:sub(-1) == '/' and '📂' or '📄'
		-- end)
		vim.cmd [[
			command! -nargs=? -complete=dir Explore Dirvish <args>
			command! -nargs=? -complete=dir Sexplore belowright split | silent Dirvish <args>
			command! -nargs=? -complete=dir Vexplore leftabove vsplit | silent Dirvish <args>
		]]
	end,
	dependencies = {
		{
			'brianhuster/dirvish-do.nvim',
			branch = 'dev',
		},
		{
			'brianhuster/dirvish-git.nvim',
			branch = 'dev'
		},
	}
}
