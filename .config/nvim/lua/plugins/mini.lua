return {
  -- Awesome Mini packages form mini.nvim bundle
  {
    "echasnovski/mini.nvim",
    version = false,
    -- event = { "VeryLazy" },
    lazy = false,
    config = function()
      local ai = require "mini.ai"
      ai.setup {
        n_lines = 120,
        custom_textobjects = {
          f = ai.gen_spec.function_call(), -- u for "Usage"
          F = ai.gen_spec.function_call { name_pattern = "[%w_]" }, -- without dot in function name
        },
      }
      require("mini.surround").setup()
      require("mini.operators").setup()
      require("mini.pairs").setup()
      require("mini.bracketed").setup()
      require("mini.files").setup {
        mappings = {
          close = "<ESC>",
          synchronize = "w",
          go_in_plus = "<CR>",
        },
        options = {
          use_as_default_explorer = false,
        },
      }

      vim.keymap.set("n", "<leader>fp", function()
        vim.cmd "lua MiniFiles.open()"
      end)

      -- require("mini.move").setup()
      require("mini.icons").setup()
      -- require("mini.icons").mock_nvim_web_devicons()
      require("mini.jump").setup()
    end,
  },
  -- {
  --   "echasnovski/mini.animate",
  --   event = "VeryLazy",
  --   opts = function(_, opts)
  --     opts.scroll = {
  --       enable = false,
  --     }
  --   end,
  -- },
  {
    "echasnovski/mini.indentscope",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    version = false,
    config = function()
      require("mini.indentscope").setup {
        symbol = "│",
        options = { try_as_border = true },
      }
    end,
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "nvterm",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },
  {
    "echasnovski/mini.move",
    version = false,
    lazy = false,

    opts = {
      -- No need to copy this inside `setup()`. Will be used automatically.
      {
        -- Module mappings. Use `''` (empty string) to disable one.
        mappings = {
          -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
          left = "<M-h>",
          right = "<M-l>",
          down = "<M-j>",
          up = "<M-k>",

          -- Move current line in Normal mode
          line_left = "<M-h>",
          line_right = "<M-l>",
          line_down = "<M-j>",
          line_up = "<M-k>",
        },

        -- Options which control moving behavior
        options = {
          -- Automatically reindent selection during linewise vertical move
          reindent_linewise = true,
        },
      },
    },
    config = function()
      require("mini.move").setup()
    end,
  },
}
