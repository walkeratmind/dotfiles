local on_atttach = require("plugins.lsp.lspconfig").on_atttach
local capabilities = require("plugins.lsp.lspconfig").capabilities

vim.g.rustaceanvim = {
  server = {
    on_atttach = on_atttach,
    capabilities = capabilities,
  },
}
