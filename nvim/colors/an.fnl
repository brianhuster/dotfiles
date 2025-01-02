(vim.cmd.highlight :clear)
(set vim.o.bg :dark)
(set vim.o.termguicolors true)

(local hl vim.api.nvim_set_hl)
(local light_blue_alternative :#FFDAB9)
(local bold_grey_alternative :pink)

(each [_ group (ipairs [:Identifier :DiagnosticHint :DiagnosticUnderlineHint])]
	(hl 0 group {:fg light_blue_alternative}))
(each [_ group (ipairs [:Title :Statement :Todo])]
	(hl 0 group {:fg bold_grey_alternative}))
