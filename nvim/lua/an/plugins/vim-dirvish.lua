---@TODO: try another icon plugin

return {
	dir = '/media/brianhuster/D/Projects/vim-dirvish',
	-- 'justinmk/vim-dirvish',
	config = function()
		vim.g.dirvish_mode = ':sort ,^.*[\\/],'
		vim.fn['dirvish#add_icon_fn'](function(p)
			local get = require('mini.icons').get
			local icon, hl, _
			if p:sub(-1) == '/' then
				icon, hl = get('directory', p)
			else
				icon, hl = get('file', p)
			end
			icon = icon .. ' '
			return { icon = icon, hl = hl }
		end)
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
			"echasnovski/mini.icons",
			config = true
		},
		-- {
		-- 	'brianhuster/dirvish-git.nvim',
		-- 	branch = 'dev'
		-- },
	}
}
