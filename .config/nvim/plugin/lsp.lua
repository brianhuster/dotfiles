local api = vim.api

vim.pack.add {'https://github.com/b0o/SchemaStore.nvim'}

vim.lsp.config.basics_ls = {
	cmd = { "basics-language-server" },
	settings = {
		buffer = {
			enable = false
		},
		path = {
			enable = true
		},
		snippet = {
			enable = true,
			sources = { vim.fs.joinpath(vim.fn.stdpath('data'),  'site/pack/core/opt/friendly-snippets/package.json') }
		}
	}
}

vim.lsp.config.lua_ls = {
	cmd = { 'lua-language-server' },
	filetypes = { 'lua' },
	root_markers = { 'lua' },
	settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT',
				path = {
					'lua/?.lua',
					'lua/?/init.lua'
				},
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
					"${3rd}/luv/library",
					"${3rd}/busted/library",
				}
			}
		}
	},
}

vim.lsp.config.json_ls = {
	cmd = { 'vscode-json-language-server', '--stdio' },
	filetypes = { 'json', 'jsonc' },
	init_options = {
		provideFormatter = true,
	},
	root_markers = { '.git' },
	settings = {
		json = {
			schemas = require('schemastore').json.schemas(),
			validate = { enable = true },
		},
	},
}

vim.lsp.config.yaml_ls = {
	cmd = { 'yaml-language-server', '--stdio' },
	filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
	root_markers = { '.git' },
	settings = {
		redhat = { telemetry = { enabled = false } },
		yaml = {
			schemaStore = {
				-- You must disable built-in schemaStore support if you want to use
				-- this plugin and its advanced options like `ignore`.
				enable = false,
				-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
				url = "",
			},
			schemas = require('schemastore').yaml.schemas(),
		},
	},
}

vim.lsp.enable {
	"arduino_language_server",
	"basics_ls",
	"dockerls",
	"bashls",
	"clangd",
	"cssls", "tailwindcss", "html", "ts_ls",
	"jsonls",
	'jdtls',
	"lua_ls",
	"marksman",
	"pylsp",
	"vue_ls",
	"vimls",
	"gopls",
	'yamlls'
}

api.nvim_create_autocmd('LspAttach', {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then return end
		if client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		end
		if vim.lsp.document_color and client:supports_method('textDocument/documentColor') then
			vim.lsp.document_color.enable(true, args.buf, { style = 'virtual' })
		end
		if client:supports_method('workspace/symbol') then
			vim.keymap.set('n', 'grs', function() vim.lsp.buf.workspace_symbol() end,
				{ buffer = args.buf, desc = 'Select LSP workspace symbol' })
		end
	end,
})

vim.keymap.set('i', '<c-space>', function()
	vim.lsp.completion.get()
end)

vim.cmd "au LspProgress * redrawstatus"

vim.diagnostic.config {
	virtual_lines = {
		current_line = true
	},
	underline = true
}

api.nvim_create_autocmd('ColorScheme', {
	callback = function()
		api.nvim_set_hl(0, 'LspReferenceTarget', {})
	end,
})

vim.lsp.inlay_hint.enable()

api.nvim_create_user_command("CopyDiagnostic", function()
	local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line('.') })
	local messages = {}
	for _, diagnostic in ipairs(diagnostics) do
		table.insert(messages, diagnostic.message or '')
	end
	vim.fn.setreg(vim.v.register, table.concat(messages, "\n"))
end, {})
