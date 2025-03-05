setl iskeyword+=.
setl keywordprg=go\ doc
setl formatprg=gofmt

nnoremap K <cmd>lua vim.lsp.buf.hover()<CR>
