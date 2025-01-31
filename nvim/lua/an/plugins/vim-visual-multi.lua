return {
	'mg979/vim-visual-multi',
	config = function()
		vim.cmd [[
			let g:vm_mouse_mappings    = 1
			let g:vm_theme             = 'iceblue'

			let g:vm_maps = {}
			let g:vm_maps["undo"]      = 'u'
			let g:vm_maps["redo"]      = '<c-r>'
		]]
	end
}
