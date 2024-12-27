local wezterm = require 'wezterm';

return {
	keys = {
		{
			key = 'Enter',
			mods = 'ALT',
			action = wezterm.action.DisableDefaultAssignment,
		},
	},
	use_ime = true,
}
