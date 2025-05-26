return {
  {
    "tadmccorkle/markdown.nvim",
    ft = "markdown", -- or 'event = "VeryLazy"'
    opts = {
      -- configuration here or empty for defaults
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      code = {
        sign = true,
        width = "block",
        right_pad = 1,
      },
      -- heading = {
      --   sign = true,
      --   icons = {},
      -- },
      checkbox = {
        enabled = true,
      },
    },
    ft = { "markdown", "norg", "rmd", "org", "codecompanion" },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      Snacks.toggle({
        name = "Render Markdown",
        get = function()
          return require("render-markdown.state").enabled
        end,
        set = function(enabled)
          local m = require "render-markdown"
          if enabled then
            m.enable()
          else
            m.disable()
          end
        end,
      }):map "<leader>um"
    end,
  },
  -- {
  --   "MeanderingProgrammer/render-markdown.nvim",
  --   -- dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
  --   -- dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" }, -- if you use standalone mini plugins
  --   event = "VeryLazy",
  --   dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
  --   ---@module 'render-markdown'
  --   ---@type render.md.UserConfig
  --   config = function(_, opts)
  --     require("render-markdown").setup(opts)
  --     Snacks.toggle({
  --       name = "Render Markdown",
  --       get = function()
  --         return require("render-markdown.state").enabled
  --       end,
  --       set = function(enabled)
  --         local m = require "render-markdown"
  --         if enabled then
  --           m.enable()
  --         else
  --           m.disable()
  --         end
  --       end,
  --     }):map "<leader>um"
  --   end,
  --
  --   opts = {},
  -- },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = function()
      require("lazy").load { plugins = { "markdown-preview.nvim" } }
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      {
        "<leader>cp",
        ft = "markdown",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview",
      },
    },
    config = function()
      vim.cmd [[do FileType]]
    end,
  },
}
