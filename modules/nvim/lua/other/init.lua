local hooks = require "ibl.hooks"

-- local highlight = {
--     "RainbowRed",
--     "RainbowYellow",
--     "RainbowBlue",
--     "RainbowOrange",
--     "RainbowGreen",
--     "RainbowViolet",
--     "RainbowCyan",
-- }
--
-- -- create the highlight groups in the highlight setup hook, so they are reset
-- -- every time the colorscheme changes
-- hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
--     vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
--     vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
--     vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
--     vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
--     vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
--     vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
--     vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
-- end)

local highlight = {
    "RainbowRedDark",
    "RainbowYellowDark",
    "RainbowBlueDark",
    "RainbowOrangeDark",
    "RainbowGreenDark",
    "RainbowVioletDark",
    "RainbowCyanDark",
}

hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, "RainbowRedDark", { fg = "#BE5046" }) -- Darker Red
    vim.api.nvim_set_hl(0, "RainbowYellowDark", { fg = "#D19A06" }) -- Darker Yellow/Gold
    vim.api.nvim_set_hl(0, "RainbowBlueDark", { fg = "#4A86E8" }) -- Darker Blue
    vim.api.nvim_set_hl(0, "RainbowOrangeDark", { fg = "#B37A38" }) -- Darker Orange/Brown
    vim.api.nvim_set_hl(0, "RainbowGreenDark", { fg = "#78A859" }) -- Darker Green
    vim.api.nvim_set_hl(0, "RainbowVioletDark", { fg = "#A052D2" }) -- Darker Violet/Purple
    vim.api.nvim_set_hl(0, "RainbowCyanDark", { fg = "#40909A" }) -- Darker Cyan/Teal
end)

vim.g.rainbow_delimiters = { highlight = highlight }

--> indent line highlights
require("ibl").setup {
    -- indent = { highlight = highlight },
    -- scope = { highlight = highlight }
}

hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
