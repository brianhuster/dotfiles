return {
	{
		'williamboman/mason.nvim',
		dependencies = {
			'williamboman/mason-lspconfig.nvim',
			'neovim/nvim-lspconfig',
		},
		config = function()
			local lang_servers = {
				"arduino_language_server",
				"bashls",
				"clangd",
				"cssls",
				"tailwindcss",
				"dockerls",
				"html",
				"ts_ls",
				"jsonls",
				'jdtls',
				"lua_ls",
				"marksman",
				"pylsp",
				"volar",
				"gopls"
			}
			require('mason').setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗"
					}
				}
			})
			require("mason-lspconfig").setup {
				ensure_installed = lang_servers,
			}
			require("mason-lspconfig").setup_handlers {
				function(server_name)
					if server_name ~= 'lua_ls' then
						require("lspconfig")[server_name].setup {}
					end
				end,
			}
		end,
	},
	{
		'mfussenegger/nvim-jdtls',
		config = function()
			vim.cmd [[
			nnoremap <A-o> <Cmd>lua require'jdtls'.organize_imports()<CR>
			nnoremap crv <Cmd>lua require('jdtls').extract_variable()<CR>
			vnoremap crv <Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>
			nnoremap crc <Cmd>lua require('jdtls').extract_constant()<CR>
			vnoremap crc <Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>
			vnoremap crm <Esc><Cmd>lua require('jdtls').extract_method(true)<CR>


			" If using nvim-dap
			" This requires java-debug and vscode-java-test bundles, see install steps in this README further below.
			nnoremap <leader>df <Cmd>lua require'jdtls'.test_class()<CR>
			nnoremap <leader>dn <Cmd>lua require'jdtls'.test_nearest_method()<CR>
		]]
		end
	},
	-- {
	-- 	--- Provides path completion via an in-process server.
	-- 	'nvimdev/phoenix.nvim'
	-- },
	{
		-- Lsp loading notifications
		'echasnovski/mini.notify',
		config = true
	}
}
