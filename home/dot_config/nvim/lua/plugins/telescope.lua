return {
  {
    "nvim-telescope/telescope.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    -- lazy = false,
    opts = function()
      return {
        defaults = {
          mappings = {
            i = {
              ["<C-J>"] = require("telescope.actions").move_selection_next,
            },
          },

          preview = {
            filetype_hook = function(_, bufnr, opts)
              -- don't display jank pdf previews
              if opts.ft == "pdf" then
                require("telescope.previewers.utils").set_preview_message(
                  bufnr,
                  opts.winid,
                  "Not displaying " .. opts.ft
                )
                return false
              end
              return true
            end,
          },
          file_ignore_patterns = {
            "node_modules",
            ".docker",
            ".git",
            "yarn.lock",
            "go.sum",
            "go.mod",
            "tags",
            "mocks",
            "refactoring",
            "^.git/",
            "^./.git/",
            "^node_modules/",
            "^build/",
            "^dist/",
            "^target/",
            "^vendor/",
            "^lazy%-lock%.json$",
            "^package%-lock%.json$",
          },
          layout_strategy = "flex",
          layout_config = {
            flex = {
              flip_columns = 120, -- switch to vertical when columns less than 120
              -- width = 0.7,
            },
            horizontal = {
              prompt_position = "bottom",
              preview_width = 0.6,
              width = 0.87,
              height = 0.80,
              -- results_width = 0.7,
            },
            vertical = {
              mirror = true,
              width = 0.9,
              height = 0.95,
            },
            preview_cutoff = 80,
          },
          file_sorter = require("telescope.sorters").get_fuzzy_file,
          generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
          path_display = { "truncate" },
          winblend = 0,
        },
        extensions_list = {
          -- "themes",
          "terms",
          -- "notify",
          "undo",
          "luasnip",
          -- "import",
          "fzf",
        },
        extensions = {
          fzf = {
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
            fuzzy = true,
          },
          import = {
            insert_at_top = true,
          },
        },
      }
    end,
    config = function()
      require("telescope").load_extension "file_browser"
      require("telescope").load_extension "frecency"
    end,
    dependencies = {
      "debugloop/telescope-undo.nvim",
      -- "gnfisher/nvim-telescope-ctags-plus",
      "benfowler/telescope-luasnip.nvim",
      "FabianWirth/search.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      { "nvim-telescope/telescope-frecency.nvim" },
      { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    },
  },

  -- extensions
  {
    "nvim-telescope/telescope-frecency.nvim",
    -- install the latest stable version
    version = "*",
    config = function()
      require("telescope").load_extension "frecency"
    end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  },
}
