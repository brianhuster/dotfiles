local colorscheme = vim.cmd.colorscheme
local o = vim.o
local hl = vim.api.nvim_set_hl

local colors = {
	purple = { fg = '#a787af', ctermfg = 139 },
	soft_cyan = { fg = "#7fdbca", ctermfg = 116 },
	light_blue = { fg = "#72aaff", ctermfg = 75 },
	peach_puff = { fg = "#FFDAB9", ctermfg = 223 },
}

colorscheme "default"
o.bg = "dark"
o.termguicolors = true

for _, group in ipairs { "Identifier", "DiagnosticHint", "DiagnosticUnderlineHint" } do
	hl(0, group, colors.light_blue)
end

for _, group in ipairs { "Title", "Statement", "Todo" } do
	hl(0, group, colors.peach_puff)
end

for _, group in ipairs { "Operator", "Delimiter" } do
	hl(0, group, colors.purple)
end

for _, group in ipairs { "PreProc", "Type", "Constant" } do
	hl(0, group, colors.soft_cyan)
end
