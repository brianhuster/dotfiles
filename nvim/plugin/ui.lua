if vim.g.loaded_config_ui then
	return
end
vim.g.loaded_config_ui = true

local cmd = vim.cmd
local api = vim.api

cmd.colorscheme 'an'

local autocmd = api.nvim_create_autocmd
if not autocmd then return end
local go_chan

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

local img_patterns = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp' }

--- credit: 3rd/image.nvim
local function get_win_size(a, b)
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

local function get_image_size(path)
	local width, height

	local result, err = vim.rpcrequest(go_chan, 'get_image_size', path)
	if not result then
		error(err)
	end
	width, height = result.width, result.height
	return {width, height}
end

autocmd('BufWinEnter', {
	pattern = img_patterns,
	callback = function()
		if not go_chan then
			go_chan = vim.fn.jobstart({'go', 'run', 'go/image.go'}, {
				rpc = true,
				cwd = vim.fn.stdpath('config'),
				on_stderr = function(_, data, _)
					vim.print(data)
				end,
				on_exit = function(_, code, _)
					if code ~= 0 then
						vim.notify("Go process exited with code " .. code, vim.log.levels.ERROR)
					end
				end
			})
		end

		local pos = api.nvim_win_get_position(0)
		local bufname = api.nvim_buf_get_name(0)
		api.nvim_buf_delete(0, {})
		cmd.enew()
		api.nvim_buf_set_name(0, bufname)

		local img_size = get_image_size(bufname)
		local img_width_in_pixels, img_height_in_pixels = img_size[1], img_size[2]
		local ws = get_win_size()
		local width = ws.col
		local height = ws.row
		local xpixel = ws.xpixel
		local ypixel = ws.ypixel
		local pix_per_row = ypixel / height
		local pix_per_col = xpixel / width
		local img_col_row_ratio = (img_width_in_pixels / pix_per_col) / (img_height_in_pixels / pix_per_row)
		local winheight = api.nvim_win_get_height(0)
		local winwidth = api.nvim_win_get_width(0)
		local win_col_row_ratio = winwidth / winheight
		local imgwidth, imgheight
		if img_col_row_ratio > win_col_row_ratio then
			imgwidth = winwidth
			imgheight = math.floor(winwidth / img_col_row_ratio)
		else
			imgheight = winheight
			imgwidth = math.floor(winheight * img_col_row_ratio)
		end
		vim.b.img = require 'an.img'.Img:new({
			row = pos[1],
			col = pos[2],
			width = imgwidth,
			height = imgheight
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
