return {
	"neovim/nvim-lspconfig",
	dependencies = {
		'netmute/ctags-lsp.nvim',
	},
	config = function()
		local api = vim.api
		api.nvim_create_autocmd('LspAttach', {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client.supports_method('textDocument/implementation') then
					api.nvim_buf_set_keymap(args.buf, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>',
						{ noremap = true, silent = true })
				end
				if client.supports_method('textDocument/completion') and vim.lsp.completion then
					vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
					vim.o.completeopt = 'menuone,noinsert,fuzzy,noselect,preview'
				end
				if client.supports_method('textDocument/formatting') then
					api.nvim_create_autocmd('BufWritePre', {
						buffer = args.buf,
						callback = function()
							if not api.nvim_buf_get_name(0):match("%.min%.") then
								vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
							end
						end,
					})
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
	end
}
