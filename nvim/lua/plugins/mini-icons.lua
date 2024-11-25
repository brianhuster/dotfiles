local extension = {
	lua = {
		glyph = '🌙',
	},
	py = {
		glyph = '🐍',
	},
	html = {
		glyph = '🌐',
	},
	css = {
		glyph = '🎨',
	},
	scss = {
		glyph = '🎨',
	},
	md = {
		glyph = '📝',
	},
	sql = {
		glyph = '💾',
	},
	c = {
		glyph = '🅒',
	},
	cpp = {
		glyph = '🅒',
	},
	h = {
		glyph = '🅒',
	},
	zig = {
		glyph = '⚡',
	},
	js = {
		glyph = '🟨',
	},
	ts = {
		glyph = '🟨',
	},
	jsx = {
		glyph = '🟨',
	},
	ada = {
		glyph = '🅐',
	},
	asm = {
		glyph = '🅐',
	},
	awk = {
		glyph = '🅐',
	},
	vue = {
		glyph = '🅥',
	},
	php = {
		glyph = '🅟',
	},
	go = {
		glyph = '🐹',
	},
	rust = {
		glyph = '🦀',
	},
	kt = {
		glyph = '🅺',
	},
	kts = {
		glyph = '🅺',
	},
	java = {
		glyph = '☕',
	},
	jsp = {
		glyph = '☕',
	},
	rb = {
		glyph = '💎',
	},
	pl = {
		glyph = '🐪',
	},
	tcl = {
		glyph = '🧩',
	},
	tex = {
		glyph = '🧾',
	},
	yaml = {
		glyph = '🧾',
	},
	yml = {
		glyph = '🧾',
	},
	toml = {
		glyph = '🧾',
	},
	json = {
		glyph = '🧾',
	},
	xml = {
		glyph = '🧾',
	},
	sh = {
		glyph = '📜',
	},
	ps1 = {
		glyph = '📜',
	},
	bat = {
		glyph = '📜',
	},
}

return {
	'echasnovski/mini.icons',
	version = false,
	config = function()
		require('mini.icons').setup({
			style = 'glyph',
			directory = {
				glyph = '📁',
			},
			file = {
				glyph = '📄',
			},
			extension = extension,
			use_file_extension = function(ext)
				return extension[ext] and extension[ext].glyph
			end,
		})
	end,
}
