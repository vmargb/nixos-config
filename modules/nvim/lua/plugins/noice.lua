require("noice").setup({
  lsp = {
    message = {
      -- Messages shown by lsp servers
      enabled = true,
      view = "mini",
    },
  },

  presets = {
    bottom_search = false, -- use a classic bottom cmdline for search
  },
  notify = {
    enabled = true,
    view = "mini",
  },
})
