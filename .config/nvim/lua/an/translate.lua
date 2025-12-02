local M = {}

-- Parse +source= and +target= from arguments
local function parse_args(args)
	local source, target = nil, "vi"
	for _, arg in ipairs(args) do
		local s = arg:match("^%+source=(.+)")
		local t = arg:match("^%+target=(.+)")
		if s then source = s end
		if t then target = t end
	end
	return source, target
end

-- Run translator and show floating window
local function run_translation(text, source, target)
	local cmd = { "trans", "-brief" }

	if source then
		table.insert(cmd, string.format(":%s", source))
	end
	if target then
		table.insert(cmd, string.format("%s", target))
	end

	table.insert(cmd, text)

	vim.system(cmd, { text = true }, function(res)
		vim.schedule(function()
			local output = res.stdout or res.stderr or "No output"
			vim.lsp.util.open_floating_preview(
				vim.split(output, "\n"),
				"plaintext",
				{ border = "rounded" }
			)
		end)
	end)
end

-- Command handler
function M.translate_cmd(opts)
	local args = opts.fargs or {}
	local source, target = parse_args(args)

	-- Get visual selection or current line
	local text = ""
	if opts.range > 0 then
		local start_line = opts.line1 - 1
		local end_line   = opts.line2
		text             = table.concat(vim.api.nvim_buf_get_lines(0, start_line, end_line, false), "\n")
	else
		text = vim.api.nvim_get_current_line()
	end

	run_translation(text, source, target)
end

function M.translate_complete(arglead, cmdline, cursorpos)
	local language_codes = {
		"am", -- Tiếng Amhara
		"ar", -- Tiếng Ả Rập
		"eu", -- Tiếng Basque
		"bn", -- Tiếng Bengal
		"en-GB", -- Tiếng Anh (Anh)
		"pt-BR", -- Tiếng Bồ Đào Nha (Brazil)
		"bg", -- Tiếng Bungary
		"ca", -- Tiếng Catalan
		"chr", -- Tiếng Cherokee
		"hr", -- Tiếng Croatia
		"cs", -- Tiếng Séc
		"da", -- Tiếng Đan Mạch
		"nl", -- Tiếng Hà Lan
		"en", -- Tiếng Anh (Mỹ)
		"et", -- Tiếng Estonia
		"fil", -- Tiếng Filipino
		"fi", -- Tiếng Phần Lan
		"fr", -- Tiếng Pháp
		"de", -- Tiếng Đức
		"el", -- Tiếng Hy Lạp
		"gu", -- Tiếng Gujarat
		"iw", -- Tiếng Do Thái (Hebrew)
		"hi", -- Tiếng Hindi
		"hu", -- Tiếng Hungary
		"is", -- Tiếng Iceland
		"id", -- Tiếng Indonesia
		"it", -- Tiếng Ý
		"ja", -- Tiếng Nhật
		"kn", -- Tiếng Kannada
		"ko", -- Tiếng Hàn
		"lv", -- Tiếng Latvia
		"lt", -- Tiếng Lithuania
		"ms", -- Tiếng Malay
		"ml", -- Tiếng Malayalam
		"mr", -- Tiếng Marathi
		"no", -- Tiếng Na Uy
		"pl", -- Tiếng Ba Lan
		"pt-PT", -- Tiếng Bồ Đào Nha (Bồ Đào Nha)
		"ro", -- Tiếng Rumani
		"ru", -- Tiếng Nga
		"sr", -- Tiếng Serbia
		"zh-CN", -- Tiếng Trung (Trung Quốc)
		"sk", -- Tiếng Slovak
		"sl", -- Tiếng Slovenia
		"es", -- Tiếng Tây Ban Nha
		"sw", -- Tiếng Swahili
		"sv", -- Tiếng Thuỵ Điển
		"ta", -- Tiếng Tamil
		"te", -- Tiếng Telugu
		"th", -- Tiếng Thái
		"zh-TW", -- Tiếng Trung (Đài Loan)
		"tr", -- Tiếng Thổ Nhĩ Kỳ
		"ur", -- Tiếng Urdu
		"uk", -- Tiếng Ukraina
		"vi", -- Tiếng Việt
		"cy", -- Tiếng Wales
    }

    if arglead:match("^%+source=") then
        return vim.iter(language_codes):map(function(code)
            return "+source=" .. code
        end):join('\n')
	elseif arglead:match("^%+target=") then
        return vim.iter(language_codes):map(function(code)
            return "+target=" .. code
        end):join('\n')
	else
		return '+source\n+target'
    end
end

return M
