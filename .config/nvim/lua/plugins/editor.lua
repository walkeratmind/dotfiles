local map = vim.keymap.set

return {
  { "eandrju/cellular-automaton.nvim", event = "VeryLazy" },
  {
    "j-hui/fidget.nvim",
    event = "VeryLazy",
    opts = {
      -- options
    },
  },
  -- https://github.com/stevearc/dressing.nvim small ui bandages in vim
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
  },
  {
    "folke/zen-mode.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    config = function()
      vim.keymap.set("n", "<leader>zz", "<cmd>ZenMode<cr>", { silent = true })
      -- limelight
      -- nmap <Leader>l <Plug>(Limelight)
      -- xmap <Leader>l <Plug>(Limelight)
    end,
  },
  {
    "folke/todo-comments.nvim",
    event = "BufReadPost",
    config = function()
      require "configs.todo"
      -- dofile(vim.g.base46_cache .. "todo")
    end,
  },
  {
    "jiaoshijie/undotree",
    dependencies = "nvim-lua/plenary.nvim",
    config = true,
    keys = { -- load the plugin only when using it's keybinding:
      { "<leader>au", "<cmd>lua require('undotree').toggle()<cr>", "Toggle undotree" },
    },
  },
  {
    "max397574/better-escape.nvim",
    config = function()
      require("better_escape").setup()
    end,
  },
  {
    "rmagatti/auto-session",
    -- lazy = false,
    event = "VeryLazy",
    config = function()
      require "configs.autosession"
    end,
  },
  {
    "cbochs/portal.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    keys = { "<leader>pj", "<leader>ph" },
  },
  {
    "nvim-telescope/telescope.nvim",
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
    dependencies = {
      "debugloop/telescope-undo.nvim",
      -- "gnfisher/nvim-telescope-ctags-plus",
      "benfowler/telescope-luasnip.nvim",
      "FabianWirth/search.nvim",
      "Marskey/telescope-sg",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
  },
  {
    "chentoast/marks.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    config = function()
      require("marks").setup {
        default_mappings = true,
        -- which builtin marks to show. default {}
        builtin_marks = { ".", "<", ">", "^" },
        -- whether movements cycle back to the beginning/end of buffer. default true
        cyclic = true,
        -- whether the shada file is updated after modifying uppercase marks. default false
        force_write_shada = false,
        -- how often (in ms) to redraw signs/recompute mark positions.
        -- higher values will have better performance but may cause visual lag,
        -- while lower values may cause performance penalties. default 150.
        refresh_interval = 250,
        -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
        -- marks, and bookmarks.
        -- can be either a table with all/none of the keys, or a single number, in which case
        -- the priority applies to all marks.
        -- default 10.
        sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
        -- disables mark tracking for specific filetypes. default {}
        excluded_filetypes = {},
        -- disables mark tracking for specific buftypes. default {}
        excluded_buftypes = {},
        -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
        -- sign/virttext. Bookmarks can be used to group together positions and quickly move
        -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
        -- default virt_text is "".
        bookmark_0 = {
          sign = "⚑",
          virt_text = "hello world",
          -- explicitly prompt for a virtual line annotation when setting a bookmark from this group.
          -- defaults to false.
          annotate = false,
        },
        mappings = {},
      }
    end,
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
    enabled = false,
        -- stylua: ignore
        keys = {
            { "s",          mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
            { "S",          mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
            { "<leader>mm", mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
            { "<leader>ms", mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
            { "<leader>mt", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
        },
  },
  {
    -- fold codeblocks
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",
    },
    event = "VeryLazy",
    init = function()
      -- vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
      -- vim.o.foldcolumn = "1" -- '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    config = function(_, opts)
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local totalLines = vim.api.nvim_buf_line_count(0)
        local foldedLines = endLnum - lnum
        local suffix = (" 󰁃 %d | %d%%"):format(foldedLines, foldedLines / totalLines * 100)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        local rAlignAppndx = math.max(math.min(vim.opt.textwidth["_value"], width - 1) - curWidth - sufWidth, 0)
        suffix = (" "):rep(rAlignAppndx) .. suffix
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end

      vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
      vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds" })
      vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "Close folds" })
      vim.keymap.set("n", "zk", function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end, { noremap = false, silent = true, desc = "Peek folded lines under cursor" })

      local ftMap = {
        vim = "indent",
        python = { "indent" },
        git = "",
      }

      require("ufo").setup {
        fold_virt_text_handler = handler,
        open_fold_hl_timeout = 150,
        close_fold_kinds_for_ft = {
          default = { "comment" },
        }, -- can add "Imports" too to fold imports
        preview = {
          win_config = {
            border = { "", "─", "", "", "", "─", "", "" },
            -- winhighlight = "Normal:Folded",
            winblend = 0,
          },
          mappings = {
            scrollU = "<C-U>",
            scrollD = "<C-D>",
          },
        },

        -- provider_selector = function(bufnr, filetype, buftype)
        --   return ftMap[filetype] or { "treesitter", "indent" }
        -- end,
        provider_selector = function(_, filetype, buftype)
          -- use nested markdown folding
          if filetype == "markdown" then
            return ""
          end

          -- return ftMap[filetype] or { "treesitter", "indent" }
          -- return { "treesitter", "indent" }
          local function handleFallbackException(bufnr, err, providerName)
            if type(err) == "string" and err:match "UfoFallbackException" then
              return require("ufo").getFolds(bufnr, providerName)
            else
              return require("promise").reject(err)
            end
          end

          -- only use indent until a file is opened
          return (filetype == "" or buftype == "nofile") and "indent"
            or function(bufnr)
              return require("ufo")
                .getFolds(bufnr, "lsp")
                :catch(function(err)
                  return handleFallbackException(bufnr, err, "treesitter")
                end)
                :catch(function(err)
                  return handleFallbackException(bufnr, err, "indent")
                end)
            end
        end,
      }
    end,
  },
  {
    "nvim-pack/nvim-spectre",
    event = { "BufRead" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  },

  {
    "christoomey/vim-tmux-navigator",
    event = { "VeryLazy" },
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
  },
  -- Utils & Disabled ones
}
