const { parse } = require('jsonc-parser')

/**
  * @param { import('neovim').NvimPlugin } plugin
  */
module.exports = (plugin) => {
	plugin.setOptions({ dev: false });
	plugin.registerFunction(
		'JsoncDecode', async (args) => {
			const [ str ] = args
			if (typeof(str) !== 'string') {
				plugin.nvim.request('nvim_echo', [
					[[ 'Error calling vimscript function JsoncDecode: expect a string' ]],
					true,
					{ err: true }
				])
				return;
			}
			return parse(str);
		},
		{ sync: true }
	);
};
