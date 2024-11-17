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
	'williamboman/mason.nvim',
	dependencies = {
		'williamboman/mason-lspconfig.nvim',
		'neovim/nvim-lspconfig',
	},
	config = function()
		local lang_servers = {
			"arduino_language_server",
			"bashls",
			"cssls",
			"tailwindcss",
			"dockerls",
			"html",
			"ts_ls",
			"jsonls",
			"lua_ls",
			"marksman",
			"phpactor",
			"pylsp",
			"volar",
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
		require('lspconfig').ccls.setup {}
	end,
}
