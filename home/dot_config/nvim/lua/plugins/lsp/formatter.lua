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
      html = { "biome", "prettier" },
      json = { "biome" },
      -- yaml = { "biome", "yamlfmt" },
      yaml = { "biome" },
      markdown = { "biome" },
      graphql = { "biome" },
      lua = { "stylua" },
      python = { "ruff_fix", "ruff_format", "ruff" },
      rust = { "rustfmt" },
      go = { "gofmt" },
      templ = { "templ" },
      sql = { "sql_formatter" },
    },
    -- format_after_save = {
    --   lsp_format = "never",
    --   async = true,
    --   timeout_ms = 1001,
    -- },
    format_on_save = {
      -- These options will be passed to conform.format()
      timeout_ms = 500,
      lsp_format = "fallback",
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
