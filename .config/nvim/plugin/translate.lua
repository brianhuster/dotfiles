vim.api.nvim_create_user_command("Translate", function(opts)
	require'an.translate'.translate_cmd(opts) end,
	{
		nargs = "*",
		range = true,
		complete = "custom,v:lua.require'an.translate'.translate_complete"
	}
)
