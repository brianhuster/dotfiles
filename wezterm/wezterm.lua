local wezterm = require 'wezterm'

return {
	use_ime = true,
	keys = {
		{
			key = 'Enter',
			mods = 'ALT',
			action = wezterm.action.DisableDefaultAssignment,
		},
	},
}
