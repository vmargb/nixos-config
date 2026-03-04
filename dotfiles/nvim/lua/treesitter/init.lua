require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "cpp", "lua", "python", "vim", "rust" },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    disable = function(lang, buf)
      local max_filesize = 100 * 1024
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      return ok and stats and stats.size > max_filesize
    end,
    additional_vim_regex_highlighting = false,
  },
  -- Refactor features now use core modules (no separate refactor table needed)
  textobjects = {  -- Replaces old refactor navigation
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
  },
  indent = { enable = true },
}
