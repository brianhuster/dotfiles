local fs = vim.fs
local config = {
	cmd = { fs.joinpath(vim.fn.stdpath('data'), 'mason/bin/jdtls') },
	root_dir = fs.dirname(fs.find({ 'gradlew', '.git', 'mvnw' }, { upward = true })[1]),
}
require('jdtls').start_or_attach(config)
