local function set_key_map()
	vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
	vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
	vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
	vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
	vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
	vim.keymap.set('n', '<Leader>B', function() require('dap').set_breakpoint() end)
	vim.keymap.set(
		'n', '<Leader>lp', function()
			require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
		end
	)
	vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
	vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)
	vim.keymap.set({ 'n', 'v' }, '<Leader>dh', function()
		require('dap.ui.widgets').hover()
	end)
	vim.keymap.set({ 'n', 'v' }, '<Leader>dp', function()
		require('dap.ui.widgets').preview()
	end)
	vim.keymap.set('n', '<Leader>df', function()
		local widgets = require('dap.ui.widgets')
		widgets.centered_float(widgets.frames)
	end)
	vim.keymap.set('n', '<Leader>ds', function()
		local widgets = require('dap.ui.widgets')
		widgets.centered_float(widgets.scopes)
	end)
end

local function js_debug_adapter()
	require("dap").adapters["pwa-node"] = {
		type = "server",
		host = "localhost",
		port = "${port}",
		executable = {
			command = "node",
			-- 💀 Make sure to update this path to point to your installation
			args = { "/home/brianhuster/.local/share/nvim/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js", "${port}" },
		}
	}
	require("dap").configurations.javascript = {
		{
			type = "pwa-node",
			request = "launch",
			name = "Launch file",
			program = "${file}",
			cwd = "${workspaceFolder}",
		},
	}
end

return {
	"rcarriga/nvim-dap-ui",
	dependencies = {
		"mfussenegger/nvim-dap",
		"nvim-neotest/nvim-nio",
	},
	config = function()
		require("dapui").setup()
		js_debug_adapter()
		set_key_map()
	end
}
