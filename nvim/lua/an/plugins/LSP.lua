local function nvim_builtin_lua_ls()
	require 'lspconfig'.lua_ls.setup {
		on_init = function(client)
			local path = client.workspace_folders[1].name
			if vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc') then
				return
			end

			client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
				runtime = {
					-- Tell the language server which version of Lua you're using
					-- (most likely LuaJIT in the case of Neovim)
					version = 'LuaJIT'
				},
				-- Make the server aware of Neovim runtime files
				workspace = {
					checkThirdParty = false,
					library = vim.api.nvim_get_runtime_file("", true)
				}
			})
		end,
		settings = {
			Lua = {}
		}
	}
end

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
					require("lspconfig")[server_name].setup {
						-- common setup for all language server
					}
				end,
				["lua_ls"] = function()
					nvim_builtin_lua_ls()
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
	{
		--- Provides path completion via an in-process server.
		'nvimdev/phoenix.nvim'
	},
	{
		-- Smart Lua development
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		-- Lsp loading notifications
		'echasnovski/mini.notify', config = true
	}
}
