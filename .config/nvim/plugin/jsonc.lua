-- plugin/jsonc.lua
-- This file configures nvim-treesitter to use the 'json' parser for 'jsonc' filetypes.

-- Check if nvim-treesitter.parsers module is available
if pcall(require, 'nvim-treesitter.parsers') then
  -- Alias 'jsonc' filetype to use the 'json' parser.
  -- The 'json' treesitter parser is capable of parsing comments,
  -- which is the primary difference in syntax for JSONC.
  require('nvim-treesitter.parsers').filetype_to_parsername.jsonc = 'json'
end

-- Ensure the 'jsonc' filetype is recognized and has Treesitter enabled
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.jsonc",
  callback = function()
    vim.bo.filetype = "jsonc"
    -- Optionally, you might want to ensure Treesitter is started for this buffer
    -- pcall(function() vim.treesitter.start() end)
  end,
  group = vim.api.nvim_create_augroup("JSONC_FileType", { clear = true }),
})
