vim.cmd.enew()
local buf = vim.api.nvim_get_current_buf()
local child_chan = vim.fn.jobstart("nvim --headless -c 'lua vim.rpcnotify(vim.fn.sockconnect([[pipe]], vim.env.NVIM, {rpc=true}), [[nvim_cmd]], {cmd=[[edit]], args={[[/tmp/x]]}}, {}) vim.cmd([[qall!]])'", {
    term = true,
    env = { NVIM = vim.v.servername },
})
vim.api.nvim_create_autocmd("BufHidden", {
    buffer = buf,
    callback = function()
        vim.fn.jobstop(child_chan)
        vim.schedule(function()
            vim.api.nvim_buf_delete(buf, { force = true })
        end)
    end,
})
