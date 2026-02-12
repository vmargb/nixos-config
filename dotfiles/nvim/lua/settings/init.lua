local o = vim.opt

--> indentation not affected by guess-indent
o.smarttab = true
o.autoindent = true

--> searching
o.hlsearch = true
o.incsearch = true
o.ignorecase = true
o.smartcase = true

--> aesthetic
o.wrap = true
--o.scrolloff = 5
o.number = true --> show line number instead of 0
o.relativenumber = true
o.cursorline = false
o.termguicolors = true

--> colors
vim.cmd("colorscheme zenbones")

--> transparency
-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

--> file stuff
o.swapfile = false
o.fileencoding = 'utf-8'
o.clipboard = 'unnamedplus'

--> others
o.hidden = true
o.splitbelow = true
o.splitright = true

--> autocmds
--> indentation affected by guess-indent
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    if o.shiftwidth == 0 then
      o.shiftwidth = 4
    end
    if o.tabstop == 0 then
      o.tabstop = 4
    end
    if o.expandtab == nil then
      o.expandtab = true
    end
  end,
})
