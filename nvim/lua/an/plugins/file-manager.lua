return {
	dir = '/media/brianhuster/D/Projects/direx.nvim',
	dependencies = {
		'echasnovski/mini.icons',
		config = true
	},
	config = function()
		require('direx.config').set {
			iconfunc = function(p)
				local get = require('mini.icons').get
				local icon, hl = get(p:sub(-1) == '/' and 'directory' or 'file', p)
				icon = icon .. ' '
				return { icon = icon, hl = hl }
			end,
		}
	end
}
