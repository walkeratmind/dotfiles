return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    {
      "windwp/nvim-ts-autotag",
      opts = { enable_close_on_slash = false },
    },
    "nvim-treesitter/nvim-treesitter-textobjects",

    {
      "JoosepAlviste/nvim-ts-context-commentstring",
      init = function()
        vim.g.skip_ts_context_commentstring_module = true
      end,
      config = function()
        require("ts_context_commentstring").setup {
          enable_autocmd = false,
        }
      end,
    },
  },
  opts = {
    auto_install = true,
    ensure_installed = {
      -- programming language
      "c",
      "cpp",
      "java",
      "kotlin",
      "python",

      "rust",

      -- Markdown
      "markdown",
      "markdown_inline",
      -- Go Lang
      "go",
      "gomod",
      "gowork",
      "gosum",

      -- Web Dev
      "javascript",
      "typescript",
      "tsx",
      "html",
      "astro",
      "css",
      "svelte",
      "html",
      "prisma",
      "graphql",

      -- 3D & webgl
      "glsl",

      "vim",
      "lua",
      "bash",
      "json",
      "json5",
      "jq",
      "yaml",
      "dockerfile",
      "regex",
      "toml",
      "gitignore",
    },
    indent = {
      enable = true,
    },
    playground = {
      enable = true,
    },
    query_linter = {
      enable = true,
      use_virtual_text = true,
      lint_events = { "BufWrite", "CursorHold" },
    },
    textsubjects = {
      enable = true,
      keymaps = {
        ["."] = "textsubjects-smart",
        [";"] = "textsubjects-container-outer",
        ["i;"] = "textsubjects-container-inner",
      },
    },
    tree_setter = {
      enable = true,
    },
    textobjects = {
      swap = {
        enable = true,
        swap_next = {
          ["Sa"] = "@parameter.inner",
        },
        swap_previous = {
          ["SA"] = "@parameter.inner",
        },
      },
    },
    rainbow = {
      enable = true,
      extended_mode = false,
      max_file_lines = 1000,
      query = {
        "rainbow-parens",
        html = "rainbow-tags",
        javascript = "rainbow-tags-react",
        tsx = "rainbow-tags",
      },
    },
    autotag = {
      enable = true,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        scope_incremental = false,
        node_decremental = "<bs>",
      },
    },
    highlight = {
      enable = true,
    },
  },
}
