local npairs = require("nvim-autopairs")
--local Rule = require('nvim-autopairs.rule')

npairs.setup({
    check_ts = true,
    ts_config = {
        lua = {'string'},-- it will not add a pair on that treesitter node
        javascript = {'template_string'},
    },
    enable_check_bracket_line = true,
})
