local api = vim.api

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

if vim.fn.has('nvim-0.11') == 1 then
	vim.diagnostic.config({
		virtual_lines = {
			current_line = true
		},
		underline = true
	})
else
	vim.diagnostic.config({
		virtual_text = false,
		-- float = true
	})
	api.nvim_create_autocmd({ "CursorMoved" }, {
		callback = function()
			vim.diagnostic.open_float(nil, { focusable = false })
		end
	})
end

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
