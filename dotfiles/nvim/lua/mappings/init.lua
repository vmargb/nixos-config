-- map leader and local map leader set in plugins

local set = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
local km = vim.keymap


--> fzf-lua mapping
km.set("n", "<leader>f", require('fzf-lua').files, { desc = "Fzf Files" })
km.set("n", "<leader>g", require('fzf-lua').live_grep, { desc = "Fzf Grep" })
km.set("n", "<leader>r", require('fzf-lua').registers, { desc = "Registers" })
km.set("n", "<leader>M", require("fzf-lua").marks, { desc = "Marks" })
km.set("n", "<leader>b", require("fzf-lua").buffers, { desc = "FZF Buffers" })
km.set("n", "<leader>cs", require("fzf-lua").colorschemes, { desc = "colourschemes" })
--> fzf-lua lsp
km.set("n", "<leader>jd", require("fzf-lua").lsp_definitions, { desc = "Jump to Definition" })
km.set("n", "<leader>jD", require("fzf-lua").lsp_declarations, { desc = "Jump to Delaration" })
km.set("n", "<leader>jt", require("fzf-lua").lsp_typedefs, { desc = "Jump to type definition" })


--[[ Telescope mapping
local builtin = require('telescope.builtin')
km.set('n', '<leader>f', builtin.find_files, {})
km.set('n', '<leader>g', builtin.live_grep, {})
km.set('n', '<leader>b', builtin.buffers, {})
km.set('n', '<leader>h', builtin.help_tags, {})
km.set('n', '<leader>r', builtin.registers, {})
km.set('n', '<leader>cs', builtin.colorscheme, {})
--> Telescope LSP
km.set('n', '<leader>jd', builtin.lsp_definitions, {})
km.set('n', '<leader>jt', builtin.lsp_type_definitions, {})
]]

--> Terminal
vim.cmd "autocmd TermOpen * startinsert"
km.set('n', '<leader>tv', ':vnew | te<CR>')
km.set('n', '<leader>th', ':new | te<CR>')
km.set('n', '<leader>teg', ':vnew | te go run .<CR>')

--> arrow
km.set("n", "<leader>p", require("arrow.persist").previous)
km.set("n", "<leader>n", require("arrow.persist").next)
km.set("n", "<C-s>", require("arrow.persist").toggle)

--> completions
km.set('i', '<C-j>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, silent = true })
km.set('i', '<C-k>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, silent = true })

--> projects
km.set("n", "<leader>o", "<Cmd>NeovimProjectDiscover<CR>")
km.set("n", "<leader>O", "<Cmd>NeovimProjectHistory<CR>")
km.set("n", "<leader>l", ":NeovimProjectLoad ")
km.set("n", "<leader>L", "<Cmd>NeovimProjectLoadRecent<CR>")


--> Others
km.set('n', '<Leader>e', ':Oil<CR>')
km.set('n', '<leader>a', ':Alpha<CR>')
km.set('n', '<leader>d', ':bd<CR>')
km.set('n', '<leader>v', ':Navbuddy<CR>')
km.set("n", "<leader>i", ':GuessIndent<CR>')

km.set('n', '//', ':noh<CR>')
km.set('n', '<leader>%', ':source %<CR>')
km.set("n", "<leader><leader>", ':ZenMode<CR>') -- zenmode
km.set("n", "<C-j>", '5<C-e>') -- jump 5 down
