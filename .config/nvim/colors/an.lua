local colorscheme = vim.cmd.colorscheme
local o = vim.o
local hl = vim.api.nvim_set_hl
local light_blue_alternative = "#82aaff"
local bold_grey_alternative = "#FFDAB9"

colorscheme "default"
o.bg = "dark"
o.termguicolors = true

for _, group in ipairs { "Identifier", "DiagnosticHint", "DiagnosticUnderlineHint" } do
	hl(0, group, { fg = light_blue_alternative })
end
for _, group in ipairs { "Title", "Statement", "Todo" } do
	hl(0, group, { fg = bold_grey_alternative })
end

local function au(name, pattern, callback)
	return vim.api.nvim_create_autocmd(name, { pattern = pattern, callback = callback })
end

au("OptionSet", { "termguicolors", "background" }, function()
	if (o.termguicolors and (o.bg == "dark")) then
		colorscheme "an"
	else
		colorscheme "default"
	end
end)
