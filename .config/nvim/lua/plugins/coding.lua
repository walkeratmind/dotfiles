return {
  {
    -- snippet plugin
    "L3MON4D3/LuaSnip",
    dependencies = "rafamadriz/friendly-snippets",
    opts = { history = true, updateevents = "TextChanged,TextChangedI" },
    config = function(_, opts)
      require("luasnip").config.set_config(opts)
      require "nvchad.configs.luasnip"
      require "configs.snippets"
    end,
  },
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    config = function(_, opts)
      require("gopher").setup(opts)
    end,
    build = function()
      vim.cmd [[silent! GoInstallDeps]]
    end,
  },
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    keys = {
      { "gcc", mode = "n", desc = "Comment toggle current line" },
      { "gc", mode = { "n", "o" }, desc = "Comment toggle linewise" },
      { "gc", mode = "x", desc = "Comment toggle linewise (visual)" },
      { "gbc", mode = "n", desc = "Comment toggle current block" },
      { "gb", mode = { "n", "o" }, desc = "Comment toggle blockwise" },
      { "gb", mode = "x", desc = "Comment toggle blockwise (visual)" },
    },
    init = function()
      vim.g.comment_maps = true
    end,
    config = function(_, opts)
      require("Comment").setup {
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      }
    end,
  },
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>tt",
        "<cmd>Trouble diagnostics toggle focus=true<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>tb",
        "<cmd>Trouble diagnostics toggle focus=true filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>ts",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>tl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<loeader>gR",
        "<cmd>Trouble lsp_references toggle<cr>",
        desc = "LSP References (Trouble)",
      },
      {
        "<leader>tL",
        "<cmd>Trouble loclist toggle focus=true<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>tf",
        "<cmd>Trouble qflist toggle focus=true<cr>",
        desc = "Quickfix List (Trouble)",
      },
      {
        "<C-l>",
        "<cmd>Trouble qflist toggle focus=true<cr>",
        desc = "Quickfix List (Trouble)",
      },
      {
        "<leader>td",
        "<cmd>Trouble todo toggle<cr>",
        desc = "Todo List (Trouble)",
      },
    },
  },

  {
    "danymat/neogen",
    -- Uncomment next line if you want to follow only stable versions
    -- version = "*"
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    config = function()
      local neogen = require "neogen"

      neogen.setup {
        snippet_engine = "luasnip",
      }
      vim.keymap.set("n", "<leader>nf", function()
        neogen.generate { type = "func" }
      end, { desc = "Neogen Generate func annotation" })

      vim.keymap.set("n", "<leader>nt", function()
        neogen.generate { type = "type" }
      end, { desc = "Neogen Generate type annotation" })
    end,
  },

  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("refactoring").setup {

        prompt_func_return_type = {
          go = true,
        },
        prompt_func_param_type = {
          go = true,
        },
      }
      vim.keymap.set("x", "<leader>re", ":Refactor extract ", { desc = "Refactor extract" })
      vim.keymap.set("x", "<leader>rf", ":Refactor extract_to_file ", { desc = "Refactor extract to file" })

      vim.keymap.set("x", "<leader>rv", ":Refactor extract_var ", { desc = "Refactor var" })

      vim.keymap.set({ "n", "x" }, "<leader>ri", ":Refactor inline_var", { desc = "Refactor inline var" })

      vim.keymap.set("n", "<leader>rI", ":Refactor inline_func", { desc = "Refactor inline func" })

      vim.keymap.set("n", "<leader>rb", ":Refactor extract_block", { desc = "Refactor extract block" })
      vim.keymap.set("n", "<leader>rbf", ":Refactor extract_block_to_file", { desc = "Refactor extract block to file" })
    end,
  },
  {
    "hedyhli/outline.nvim",
    event = { "LspAttach" },
    config = function()
      require("outline").setup {}
      vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>", { desc = "Toggle Outline" })
    end,
  },
  {
    "aznhe21/actions-preview.nvim",
    event = { "LspAttach" },
    config = function()
      vim.keymap.set({ "v", "n" }, "gf", require("actions-preview").code_actions)
    end,
  },
  {
    "michaelb/sniprun",
    branch = "master",

    build = "sh install.sh",
    -- do 'sh install.sh 1' if you want to force compile locally
    -- (instead of fetching a binary from the github release). Requires Rust >= 1.65
    event = { "LspAttach" },

    config = function()
      require("sniprun").setup {
        -- your options
        repl_enable = { "ipython" },
      }
      vim.api.nvim_set_keymap({ "n", "v" }, "<leader>sr", "<Plug>SnipRun", { silent = true })
      vim.api.nvim_set_keymap("n", "<leader>sf", "<Plug>SnipRunOperator", { silent = true })
    end,
  },
}
