return {
  "mfussenegger/nvim-lint", -- configure formatters & linters
  lazy = true,
  -- event = { "BufReadPre", "BufNewFile" },
  -- event = "BufWritePre",
  event = "LspAttach",
  config = function()
    local _, lint = pcall(require, "lint")
    lint.linters_by_ft = {
      lua = {
        "luacheck",
      },
      go = { "golangcilint" },
      python = { "ruff" },
      json = { "biomejs" },
      javascript = { "biomejs" },
      typescript = { "biomejs" },
      javascriptreact = { "biomejs" },
      typescriptreact = { "biomejs" },
      svelte = { "biomejs" },
      markdown = { "vale" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
    -- vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    --   group = lint_augroup,
    --   callback = function()
    --     lint.try_lint()
    --   end,
    -- })
    --
    vim.keymap.set("n", "<leader>ll", function()
      lint.try_lint()
    end, { desc = "trigger linting for current file" })
  end,
}
