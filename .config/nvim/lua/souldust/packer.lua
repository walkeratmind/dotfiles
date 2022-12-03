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

  -- LSP
  use("neovim/nvim-lspconfig")
  use("hrsh7th/cmp-nvim-lsp")
  use("hrsh7th/cmp-buffer")
  use("hrsh7th/nvim-cmp")

  -- Lua
  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons"
  }
  -- tabnine for autocompletion
  use {'tzachar/cmp-tabnine', run='./install.sh', requires = 'hrsh7th/nvim-cmp'}
  use("ray-x/lsp_signature.nvim")

  use("onsails/lspkind-nvim")
  use("glepnir/lspsaga.nvim")
  use("L3MON4D3/LuaSnip")
  use("saadparwaiz1/cmp_luasnip")

  use 'nvim-lualine/lualine.nvim' -- Statusline
  use("simrat39/symbols-outline.nvim") -- outline the tree view for symbols
  use("mbbill/undotree") -- show last undo in tree view
  use 'kyazdani42/nvim-web-devicons' -- File icons


  use("sbdchd/neoformat")
  use 'MunifTanjim/prettier.nvim' -- Prettier plugin for Neovim's built-in LSP client
  use('jose-elias-alvarez/null-ls.nvim')

  use("nvim-treesitter/nvim-treesitter", {
      run = ":TSUpdate"
  })
  use("nvim-treesitter/playground")
  use("romgrk/nvim-treesitter-context")

  use 'windwp/nvim-autopairs'
  use 'windwp/nvim-ts-autotag'
  use 'norcalli/nvim-colorizer.lua'

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
end)
