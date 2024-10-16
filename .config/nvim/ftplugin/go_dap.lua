if _G.loaded_dap_go or vim.g.vscode then
	return
end
_G.loaded_dap_go = true

require('dap-go').setup()
