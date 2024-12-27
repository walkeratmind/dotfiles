local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.ensure_installed({
  "tsserver",
  "rust_analyzer",
})

lsp.on_attach(function(client, bufnr)
  local opts = { buffer = bufnr, remap = false }

  nnoremap("<leader>d", function()
    vim.lsp.buf.definition()
  end)
  nnoremap("<leader>k", function()
    vim.lsp.buf.hover()
  end)
  nnoremap("<leader>vws", function()
    vim.lsp.buf.workspace_symbol()
  end)
  nnoremap("<leader>vd", function()
    vim.diagnostic.open_float()
  end)
  nnoremap("<leader>gd", "<Cmd>Lspsaga lsp_finder<CR>")
  nnoremap("gn", function()
    vim.diagnostic.goto_next()
  end)
  nnoremap("gp", function()
    vim.diagnostic.goto_prev()
  end)
  nnoremap("<leader>vca", function()
    vim.lsp.buf.code_action()
  end)
  nnoremap("<leader>vrr", function()
    vim.lsp.buf.references()
  end)
  nnoremap("<leader>vrn", function()
    vim.lsp.buf.rename()
  end)
  nnoremap("<F2>", function()
    vim.lsp.buf.rename()
  end)
  inoremap("<C-h>", function()
    vim.lsp.buf.signature_help()
  end)
end)

lsp.setup()
