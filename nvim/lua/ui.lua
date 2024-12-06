local cmd = vim.cmd

cmd.colorscheme('default')

local nvim_light_blue = "#7fadcc"
cmd.highlight("Identifier", "guifg=" .. nvim_light_blue)
cmd.highlight("DiagnosticHint", "guifg=" .. nvim_light_blue)
cmd.highlight("DiagnosticUnderlineHint", "guifg=" .. nvim_light_blue)
local autocmd = vim.api.nvim_create_autocmd
if not autocmd then return end

autocmd('BufEnter', {
	pattern = '*',
	callback = function()
		if vim.bo.buftype == 'terminal' then
			vim.wo.number = false
			vim.o.winheight = 12
		elseif vim.bo.buftype == 'nofile' then
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, true, true), 'n', true)
		else
			vim.o.winheight = 100
		end
	end
})

local img_patterns = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp' }
vim.cmd.py3('from image import get_image_size')

autocmd('BufWinEnter', {
	pattern = img_patterns,
	callback = function()
		local pos = vim.api.nvim_win_get_position(0)
		local bufname = vim.api.nvim_buf_get_name(0)
		vim.api.nvim_buf_delete(0, {})
		vim.cmd.enew()
		vim.api.nvim_buf_set_name(0, bufname)

		local img_size = vim.fn.py3eval('get_image_size(vim.current.buffer.name)')
		local img_width, img_height = img_size[1], img_size[2]
		local width = vim.api.nvim_win_get_width(0)
		local height = vim.api.nvim_win_get_height(0)
		print((img_width / width) / (img_height / height / 2))
		print(img_width / width < img_height / height / 2 and height)
		vim.b.img = require('img').Img:new({
			row = pos[1] + 7,
			col = pos[2],
			width = img_width / width >= img_height / height / 2 and width,
			height = img_width / width < img_height / height / 2 and height
		})
		vim.b.img:show({ filename = bufname })
	end
})

autocmd('BufLeave', {
	pattern = img_patterns,
	callback = function()
		vim.b.img:hide()
	end
})
