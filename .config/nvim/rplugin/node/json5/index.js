const { parse } = require('json5')

/**
  * @param { import('neovim').NvimPlugin } plugin
  */
module.exports = (plugin) => {
	plugin.setOptions({ dev: false });
	plugin.registerFunction(
		'Json5Decode', async (args) => {
			const [ str ] = args
			if (typeof(str) !== 'string') {
				plugin.nvim.request('nvim_echo', [
					[[ 'Error calling vimscript function Json5Decode: expect a string' ]],
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
