--- This file is for Nvim-embedded Lua
local filepath = vim.fs.normalize(vim.api.nvim_buf_get_name(0))

---@return boolean
local function is_nvim_lua()
	local nvim_lua = vim.g.nvim_lua
	if nvim_lua == 0 or nvim_lua == false then
		return false
	end
	if nvim_lua then
		return true
	end
	local runtime_paths = vim.api.nvim_list_runtime_paths()
	for _, rtp in ipairs(runtime_paths) do
		if vim.startswith(filepath, rtp .. '/') then
			return true
		end
	end
	return false
end

if not is_nvim_lua() then
	return
end

vim.g.lua_version = 5
vim.g.lua_subversion = 1

vim.bo.path = nil
vim.bo.omnifunc = "v:lua.vim.lua_omnifunc"
vim.bo.includeexpr = "v:lua.require'an.lua'.includeexpr()"
if not vim.b.root_dir then
	vim.b.root_dir = require('an.lua').find_root(vim.api.nvim_buf_get_name(0))
end

vim.keymap.set('n', '<C-k>', function()
	require 'an.lua'.keywordexpr()
end, { buffer = true })

vim.api.nvim_create_autocmd('LspAttach', {
	buffer = 0,
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then return end
		if client:supports_method('textDocument/completion') then
			vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'
		end
	end,
})

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or '')
	.. '\n lua vim.treesitter.stop() \n setl omnifunc< includeexpr< \n nunmap <buffer> <C-k> \n'
