local cmd = vim.cmd
local api = vim.api

cmd.colorscheme 'an'

local autocmd = api.nvim_create_autocmd
if not autocmd then return end

autocmd('BufEnter', {
	pattern = '*',
	callback = function()
		if vim.bo.buftype == 'terminal' and vim.bo.ft ~= 'fzf' then
			vim.wo.number = false
			vim.o.winheight = 12
		else
			vim.o.winheight = 100
		end
	end
})

--- Image preview
local img_patterns = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp' }
cmd.py3 'from image import get_image_size'

--- credit: 3rd/image.nvim
local function get_win_size()
	local ffi = require('ffi')
	ffi.cdef([[
		typedef struct {
			unsigned short row;
			unsigned short col;
			unsigned short xpixel;
			unsigned short ypixel;
		} winsize;
		int ioctl(int fd, int request, winsize *ws);
	]])

	local TIOCGWINSZ = nil
	if ffi.os:lower() == 'linux' then
		TIOCGWINSZ = 0x5413
	elseif ffi.os:lower() == 'bsd' or ffi.os:lower() == 'macos' then
		TIOCGWINSZ = 0x40087468
	end

	---@type {row: number, col: number, xpixel: number, ypixel: number}
	local ws = ffi.new('winsize')
	assert(ffi.C.ioctl(0, TIOCGWINSZ, ws) == 0, 'Failed to get window size')
	return ws
end

autocmd('BufWinEnter', {
	pattern = img_patterns,
	callback = function()
		local pos = api.nvim_win_get_position(0)
		local bufname = api.nvim_buf_get_name(0)
		api.nvim_buf_delete(0, {})
		cmd.enew()
		api.nvim_buf_set_name(0, bufname)

		local img_size = vim.fn.py3eval('get_image_size(vim.current.buffer.name)')
		local img_width, img_height = img_size[1], img_size[2]
		local ws = get_win_size()
		local width = ws.col
		local height = ws.row
		local xpixel = ws.xpixel
		local ypixel = ws.ypixel
		local winratio = xpixel / ypixel
		local imgratio = img_width / img_height
		if winratio < imgratio then
			height = math.min(height, img_height)
			width = math.floor(height * winratio)
		else
			width = math.min(width, img_width)
			height = math.floor(width / winratio)
		end
		vim.b.img = require('img').Img:new({
			row = pos[1] + 7,
			col = pos[2],
			width = width,
			height = height
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
