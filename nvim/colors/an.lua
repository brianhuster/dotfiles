vim.cmd.highlight 'clear'
vim.o.bg = 'dark'
vim.o.termguicolors = true

local hl = vim.api.nvim_set_hl

local light_blue_alternative = "#FFDAB9"
local bold_grey_alternative = "pink"

for _, group in ipairs { 'Identifier', 'DiagnosticHint', 'DiagnosticUnderlineHint' } do
	hl(0, group, { fg = light_blue_alternative })
end

for _, group in ipairs { 'Title', 'Statement', 'Todo' } do
	hl(0, group, { fg = bold_grey_alternative })
end
