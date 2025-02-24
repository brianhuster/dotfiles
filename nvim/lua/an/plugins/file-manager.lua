return {
	dir = '/media/brianhuster/D/Projects/dir.nvim',
	dependencies = {
		'echasnovski/mini.icons',
		config = true
	},
	config = function()
		require('dir.config').set {
			iconfunc = function(p)
				local get = require('mini.icons').get
				local icon, hl = get(p:sub(-1) == '/' and 'directory' or 'file', p)
				icon = icon .. ' '
				return { icon = icon, hl = hl }
			end
		}
		vim.keymap.set({ 'n', 'x' }, '<leader>f', ':<C-u>Find<Space>', {
			desc = 'Find file'
		})
	end
}
