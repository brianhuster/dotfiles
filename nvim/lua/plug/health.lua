return {
	check = function()
		vim.health.start "List of plugins"
		vim.health.info(vim.inspect(require('plug').Pkgs))
	end,
}
