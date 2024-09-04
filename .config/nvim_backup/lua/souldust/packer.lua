return require("packer").startup(function()
  use("wbthomason/packer.nvim")

  use("TimUntersberger/neogit")

  -- telescope requirements
  use("nvim-lua/plenary.nvim")
  use("nvim-lua/popup.nvim")

  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }  -- telescope extensions
  use 'cljoly/telescope-repo.nvim'

  -- file browser within telescope
  use { "nvim-telescope/telescope-file-browser.nvim" }
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  -- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation
  use {
    'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
  }
  use("nvim-treesitter/playground")
  use("romgrk/nvim-treesitter-context")
  use("theprimeagen/harpoon")

  use 'nvim-lualine/lualine.nvim' -- Statusline
  use("simrat39/symbols-outline.nvim") -- outline the tree view for symbols
  use("mbbill/undotree") -- show last undo in tree view
  use 'kyazdani42/nvim-web-devicons' -- File icons
  use("tpope/vim-fugitive") -- git wrapper

  use("sbdchd/neoformat")
  use 'MunifTanjim/prettier.nvim' -- Prettier plugin for Neovim's built-in LSP client
  use('jose-elias-alvarez/null-ls.nvim')

  use 'windwp/nvim-autopairs'
  use 'windwp/nvim-ts-autotag'
  use 'norcalli/nvim-colorizer.lua'

    -- LSP
    use {
      'VonHeikemen/lsp-zero.nvim',
      branch = 'v1.x',
      requires = {
        -- LSP Support
        {'neovim/nvim-lspconfig'},
        {'williamboman/mason.nvim'},
        {'williamboman/mason-lspconfig.nvim'},

        -- Autocompletion
        {'hrsh7th/nvim-cmp'},
        {'hrsh7th/cmp-buffer'},
        {'hrsh7th/cmp-path'},
        {'saadparwaiz1/cmp_luasnip'},
        {'hrsh7th/cmp-nvim-lsp'},
        {'hrsh7th/cmp-nvim-lua'},

        -- Snippets
        {'L3MON4D3/LuaSnip'},
        {'rafamadriz/friendly-snippets'},
        {'saadparwaiz1/cmp_luasnip'},

        {'glepnir/lspsaga.nvim'},
        -- vscode like pictograms in suggestion
        {'onsails/lspkind-nvim'},

      }
    }
  use("ray-x/lsp_signature.nvim")


    -- Lua
    use {
      "folke/trouble.nvim",
      requires = "kyazdani42/nvim-web-devicons"
    }

  -- Debugger Plugin
  use("mfussenegger/nvim-dap")
  use("rcarriga/nvim-dap-ui")
  use("theHamsta/nvim-dap-virtual-text")

   -- Colorscheme
  use("gruvbox-community/gruvbox")
  use("folke/tokyonight.nvim")

  -- Zen mode
  use("folke/zen-mode.nvim")
  use("junegunn/limelight.vim")

  -- higlight todo
  use {
    "folke/todo-comments.nvim",
    requires = "nvim-lua/plenary.nvim"
  }

  -- language specific
  use 'ray-x/go.nvim'
  use 'ray-x/guihua.lua' -- recommanded if need floating window support

  -- navigate between vim and tmux smoothly
  use 'christoomey/vim-tmux-navigator'
end)
