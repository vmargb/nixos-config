-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ' '
vim.g.maplocalleader = "\\"

local plugins = {
    --> General
    'windwp/nvim-autopairs',
    { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' },
    'nvim-treesitter/nvim-treesitter-refactor',
    {
      "folke/flash.nvim",
      event = "VeryLazy",
      ---@type Flash.Config
      opts = {},
      -- stylua: ignore
      keys = {
        { "z", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
        { "Z", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
        { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
        { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
        { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
      },
    },
    { 'echasnovski/mini.comment', version = '*' }, -- gcc, vgc
    { -- saiw{pair} or v->sa{pair}, sr{oldpair}{newpair}, sd to delete a pair
        'echasnovski/mini.surround', version = '*',
        config = function() require('mini.surround').setup() end
    },
    {
      'Exafunction/codeium.vim',
      event = 'BufEnter'
    },
    { 'lewis6991/gitsigns.nvim',
      config = function() require('gitsigns').setup() end
    },

    --> Files
    {
      "ibhagwan/fzf-lua",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("fzf-lua").setup({})
      end
    },
    { -- ` switch directory, _ return
      'stevearc/oil.nvim',
      ---@module 'oil'
      ---@type oil.SetupOpts
      opts = {},
      --dependencies = { { "echasnovski/mini.icons", opts = {} } },
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function() require("oil").setup({
          view_options = {
            show_hidden = true,
          },
          -- float {
          --     padding = 2,
          --     max_width = 90,
          --     max_height = 0,
          -- },
        })
      end
    },
    {
      "otavioschwanck/arrow.nvim",
      dependencies = {
        { "nvim-tree/nvim-web-devicons" },
        -- or if using `mini.icons`
        -- { "echasnovski/mini.icons" },
      },
      opts = {
        show_icons = true,
        leader_key = '<leader>m', -- Recommended to be a single key
        buffer_leader_key = 'm', -- Per Buffer Mappings
      }
    },

    --> Aesthetic
    { "nvim-tree/nvim-web-devicons", lazy = true },
    'nvim-lualine/lualine.nvim',
    { "folke/zen-mode.nvim" },
    { "folke/twilight.nvim" },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        ---@module "ibl"
        ---@type ibl.config
        opts = {},
    },
    { 'HiPhish/rainbow-delimiters.nvim' },
    {
        'goolord/alpha-nvim',
        dependencies = {
            'echasnovski/mini.icons',
            'nvim-lua/plenary.nvim'
        },
        config = function ()
            require'alpha'.setup(require'alpha.themes.theta'.config)
        end
    },
    {
      "folke/noice.nvim",
      event = "VeryLazy",
      opts = {
      },
      dependencies = { "MunifTanjim/nui.nvim" }
    },
    {
        "HampusHauffman/block.nvim",
        config = function()
            require("block").setup({})
        end
    },

    --> Colorschemes
    { "slugbyte/lackluster.nvim" },
    { 'mellow-theme/mellow.nvim' },
    { "yorumicolors/yorumi.nvim" },
    { "presindent/ethereal.nvim" },
    { "love-pengy/lillilac.nvim" },
    { "rose-pine/neovim", name = "rose-pine" },
    {
      "xero/miasma.nvim",
      lazy = false,
      priority = 1000,
    },
    { "savq/melange-nvim" },
    { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false, priority = 1000 },
    {
        "zenbones-theme/zenbones.nvim",
        -- Optionally install Lush. Allows for more configuration or extending the colorscheme
        dependencies = "rktjmp/lush.nvim",
        lazy = false,
        priority = 1000,
        -- config = function()
        --     vim.g.zenbones_darken_comments = 45
        --     vim.cmd.colorscheme('zenbones')
        -- end
    },
    { "ayu-theme/ayu-vim" },

    --> Mason + lsp stuff
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            {
                "SmiteshP/nvim-navbuddy",
                dependencies = {
                    "SmiteshP/nvim-navic",
                    "MunifTanjim/nui.nvim"
                },
                opts = { lsp = { auto_attach = true } }
            }
        },
    },
    { 'williamboman/mason.nvim' },
    {
        'williamboman/mason-lspconfig.nvim',
        -- ensures that mason is loaded first
        dependencies = { "mason.nvim" },
    },
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "VeryLazy", -- Or `LspAttach`
        priority = 1000, -- needs to be loaded in first
        config = function()
            require('tiny-inline-diagnostic').setup()
            vim.diagnostic.config({ virtual_text = false }) -- Only if needed in your configuration, if you already have native LSP diagnostics
        end
    },

    --> Projects
    {
      "coffebar/neovim-project",
      opts = {
        projects = { -- define project roots
          "~/projects/*",
          "~/.config/",
        },
        picker = { type = "fzf-lua" }
      },
      init = function()
        vim.opt.sessionoptions:append("globals")
      end,
      dependencies = {
        { "nvim-lua/plenary.nvim" },
        { "Shatur/neovim-session-manager" },
      },
      lazy = false,
      priority = 100,
    },
    {
      "davmacario/nvim-quicknotes",
      keys = { "<leader>qn" },
      cmd = { "Quicknotes", "QuicknotesClear", "QuicknotesCleanup" }, -- Lazy-load the plugin
      -- <<<

      config = function()
        require("nvim-quicknotes").setup()

        -- Custom keymap
        vim.keymap.set("n", "<leader>qn", vim.cmd.Quicknotes, { desc = "Open quicknotes" })
      end,
    },

    --> Misc (load last)
    {
      'nmac427/guess-indent.nvim',
      config = function() require('guess-indent').setup {} end,
    },
}

local opts = {}

require("lazy").setup(plugins, opts)
