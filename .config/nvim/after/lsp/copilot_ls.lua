local VIM = vim.env.VIM

---@type vim.lsp.Config
return {
	cmd = { 'copilot-language-server', '--stdio' },
	cmd_cwd = vim.fn.isdirectory(VIM) and VIM or vim.env.HOME,
	name = 'copilot_ls',
	root_markers = { '.git' },
	init_options = {
		editorInfo = {
			name = 'Neovim',
			version = tostring(vim.version())
		},
		editorPluginInfo = {
			name = 'copilot_ls',
			version = '0.1.0'
		}
	},
	handlers = {
		['textDocument/inlineCompletion'] = function(...)
			vim.print(...)
		end
	},
	---@param client vim.lsp.Client
	---@param bufnr integer
	on_attach = function(client, bufnr)
		vim.keymap.set('i', '<M-c>', function()
			client:request('textDocument/inlineCompletion', {
				textDocument = {
					uri = vim.uri_from_bufnr(bufnr),
				},
				position = {
					line = vim.fn.line('.'),
					character = vim.fn.col('.')
				},
				context = {
					triggerKind = 1,
				}
			})
		end)
	end
}
