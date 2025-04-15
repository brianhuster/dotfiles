if _G.loaded_dap_go then
	return
end
_G.loaded_dap_go = true

require('dap-go').setup()
