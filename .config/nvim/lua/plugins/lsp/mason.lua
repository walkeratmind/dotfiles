return {
  {
    "williamboman/mason.nvim",
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "dockerfile-language-server",
        "yaml-language-server",

        -- golang
        "gopls",
        "golangci-lint",
        "goimports",
        "golines",
        "gomodifytags",
        "impl",
        -- formatting
        "biome",
        "prettier", -- prettier formatter
        "stylua", -- lua formatter
        "ruff",

        "pylint", -- python linter
        "eslint_d", -- js linter
        "luacheck", -- linter for lua
        -- "gofmt",
        -- "rustfmt",
      },

      ui = {
        icons = {
          package_pending = " ",
          package_installed = "󰄳 ",
          package_uninstalled = "󰇚 ",
        },

        keymaps = {
          toggle_server_expand = "<CR>",
          install_server = "i",
          update_server = "u",
          check_server_version = "c",
          update_all_servers = "U",
          check_outdated_servers = "C",
          uninstall_server = "X",
          cancel_installation = "<C-c>",
        },
      },
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = "VeryLazy",
    config = function()
      local mason_lspconfig = require "mason-lspconfig"

      mason_lspconfig.setup {
        -- list of servers for mason to install
        ensure_installed = {
          "ts_ls",
          "html",
          "htmx",
          "cssls",
          "tailwindcss",
          "svelte",
          "lua_ls",
          "emmet_ls",
          "prismals",
          "pyright",
          "rust_analyzer",

          "gopls",
          "golangci_lint_ls",
          "templ",

          "graphql",
        },
        -- auto-install configured servers (with lspconfig)
        automatic_installation = false, -- not the same as ensure_installed
      }
    end,
  },
}
