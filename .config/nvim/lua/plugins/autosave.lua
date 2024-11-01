local function toggle_autosave_if_in_nvim_config(command, toggle_arg)
	local cwd = vim.fn.getcwd()

	local home = vim.fn.expand("~")

	local nvim_config_dir = home .. "/.config/nvim"

	if cwd:sub(1, #nvim_config_dir) == nvim_config_dir then
		vim.cmd(command .. " " .. toggle_arg)
	end
end

local opts = {
	command = "Autosave",
	toggle_arg = "toggle",
	status_arg = "status",
}

return {
	"brianhuster/autosave.nvim",
	branch = "dev",
	lazy = false,
	event = "InsertEnter",
	config = function()
		toggle_autosave_if_in_nvim_config(opts.command, opts.toggle_arg)
	end
}
