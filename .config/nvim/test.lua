local plugins = {
	"acp.nvim",
	"direx.nvim",
	"live-preview.nvim",
	"qfpeek.nvim",
	"unnest.nvim",
}

for _, plug in ipairs(plugins) do
	print(vim.fn.system({ "git", "submodule", "add", "https://github.com/brianhuster/" .. plug,
		"pack/mine/opt/" .. plug }))
end
