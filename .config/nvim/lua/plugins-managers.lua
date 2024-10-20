-- Vô hiệu hóa các plugin mặc định không cần thiết trong Neovim
local disabled_built_ins = {
	"getscript",
	"getscriptPlugin",
	"logipat",
	"matchit",
	"rrhelper",
	"spellfile_plugin",
	"vimball",
	"vimballPlugin",
	"tutor",
	"rplugin",
	"compiler",
	"bugreport",
	"ftplugin",
	"netrw",
	"netrwPlugin",
	"netrwSettings",
	"netrwFileHandlers",
	"gzip",
	"zip",
	"zipPlugin",
	"tar",
	"tarPlugin"
}

for _, plugin in pairs(disabled_built_ins) do
	vim.g["loaded_" .. plugin] = 1
end

-- Install lazy.nvim if not exists
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end

-- If running in VSCode, skip installing or loading plugins
if vim.g.vscode then
	return
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{ import = "plugins" },
})
