return {
	"neovim/nvim-lspconfig",
	config = function()
		vim.api.nvim_create_autocmd('LspAttach', {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client.supports_method('textDocument/implementation') then
					vim.api.nvim_buf_set_keymap(args.buf, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>',
						{ noremap = true, silent = true })
				end
				if client.supports_method('textDocument/completion') and vim.lsp.completion then
					vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
					vim.o.completeopt = 'menuone,noinsert,fuzzy,noselect'
				end
				if client.supports_method('textDocument/formatting') then
					vim.api.nvim_create_autocmd('BufWritePre', {
						buffer = args.buf,
						callback = function()
							vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
						end,
					})
				end
			end,
		})
		vim.api.nvim_create_autocmd({ "CursorMoved" }, {
			callback = function()
				vim.diagnostic.config({
					virtual_text = false,
				})
				vim.diagnostic.open_float(nil, { focusable = false })
			end,
		})
	end
}
