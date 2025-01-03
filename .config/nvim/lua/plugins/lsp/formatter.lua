local prettier = { "prettierd", "prettier" }
return {
  "stevearc/conform.nvim",
  event = "BufReadPost",
  opptional = true,
  opts = {
    formatters_by_ft = {
      javascript = { "biome" },
      typescript = { "biome" },
      javascriptreact = { "biome" },
      typescriptreact = { "biome" },
      svelte = { "biome" },
      css = { "biome" },
      html = { "biome" },
      json = { "biome" },
      yaml = { "biome" },
      markdown = { "biome" },
      graphql = { "biome" },
      lua = { "stylua" },
      python = { "ruff" },
      rust = { "rustfmt" },
      go = { "gofmt" },
    },
    format_on_save = {
      lsp_fallback = false,
      async = false,
      timeout_ms = 1001,
    },
  },
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    vim.keymap.set({ "n", "v" }, "<leader>mf", function()
      require("conform").format {
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      }
    end, { desc = "Format file or range (in visual mode)" })
  end,
}
