local api, fn = vim.api, vim.fn

if fn.has("win32") == 1 then
    return
end

api.nvim_create_user_command("Fish", function(opts)
    local cmd = "fish -c " .. fn.shellescape(opts.args)
    fn.system(cmd)
end, {
    nargs = 1,
    complete = function(arg_lead, cmd_line, cursor_pos)
        local cmd = string.sub(cmd_line, 1, cursor_pos)
        local parsed_cmd = api.nvim_parse_cmd(cmd, {})
        local args = parsed_cmd.args
        if #args == 0 then
            return {}
        end
        local base_cmd = args and args[1] or ""
        local arg_lead_expanded = fn.expand(arg_lead)
		return vim.iter(fn["an#fish#Complete"](base_cmd))
            :map(function(item)
                return item.word
            end)
            :filter(function(item)
				return vim.startswith(item, arg_lead_expanded)
            end)
            :totable()
    end,
})
