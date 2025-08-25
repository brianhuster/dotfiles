if vim.g.loaded_difftool_plugin ~= nil then
  return
end
vim.g.loaded_difftool_plugin = true

vim.api.nvim_create_user_command('DiffTool', function(opts)
  if #opts.fargs == 2 then
    require('an.diff').diff(opts.fargs[1], opts.fargs[2])
  else
    vim.notify('Usage: DiffTool <left> <right>', vim.log.levels.ERROR)
  end
end, { nargs = '*', complete = "file" })
