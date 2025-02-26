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
			end,
			remove = 'permanent',
			keymaps = {
				paste = 'gp',
				copy = 'gy',
				cut = 'gd',
				preview = 'P',
				mkdir = 'gmd',
				mkfile = 'gmf',
				argadd = 'gaa',
				argdelete = 'gad'
			}
		}
		vim.keymap.set({ 'n', 'x' }, '<leader>f', ':<C-u>FindFile<Space>', {
			desc = 'Find file'
		})
	end
}
