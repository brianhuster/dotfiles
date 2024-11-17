return {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {
        map_cr = true
    },
    config = function()
        local npairs = require('nvim-autopairs')
        npairs.setup({ map_cr = false })

        -- skip it, if you use another global object
    end,
}
