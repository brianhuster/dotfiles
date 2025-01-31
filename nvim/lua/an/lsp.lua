local api = vim.api

api.nvim_create_autocmd('LspAttach', {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client:supports_method('textDocument/completion') and vim.lsp.completion then
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
			vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'
			vim.cmd([[autocmd! InsertCharPre <buffer> call InsAutocomplete()]])
		end

		if client and client:supports_method('textDocument/formatting') then
			api.nvim_create_autocmd('BufWritePre', {
				buffer = args.buf,
				callback = function()
					if not api.nvim_buf_get_name(0):match("%.min%.") then
						vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
					end
				end,
			})
		end
		local capabilities = vim.lsp.get_client_by_id(args.data.client_id).server_capabilities
		if capabilities and capabilities.renameProvider then
			vim.keymap.set("n", "grn", function() vim.lsp.buf.rename() end, { buffer = true })
		end
	end,
})

api.nvim_create_autocmd({ "CursorMoved" }, {
	callback = function()
		vim.diagnostic.config({
			virtual_text = false,
		})
		vim.diagnostic.open_float(nil, { focusable = false })
	end,
})

api.nvim_create_user_command("CopyDiagnostic", function()
	local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line('.') })
	local messages = {}
	for _, diagnostic in ipairs(diagnostics) do
		table.insert(messages, diagnostic.message or '')
	end
	vim.fn.setreg(vim.v.register, table.concat(messages, "\n"))
end, {})
