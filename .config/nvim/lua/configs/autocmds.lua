local autocmd = vim.api.nvim_create_autocmd

local augroup = vim.api.nvim_create_augroup
local souldust = augroup("souldust", { clear = true })

local map = vim.keymap.set

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = souldust,
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- run lint on events and show message
local lint_augroup = augroup("lint", { clear = true })
local lint = require "lint"
autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = lint_augroup,
  callback = function()
    vim.defer_fn(function()
      lint.try_lint()
    end, 2000)
  end,
})

-- update cursor position for harpoon when buffer closes
-- autocmd({ "BufLeave", "ExitPre" }, {
--   group = souldust,
--   pattern = "*",
--   callback = function()
--     local filename = vim.fn.expand "%:p:."
--     local harpoon_marks = require("harpoon"):list().items
--     for _, mark in ipairs(harpoon_marks) do
--       if mark.value == filename then
--         mark.context.row = vim.fn.line "."
--         mark.context.col = vim.fn.col "."
--         return
--       end
--     end
--   end,
-- })

autocmd("LspAttach", {
  group = souldust,
  callback = function()
    -- lsp
    map("n", "<leader>rs", "<cmd>LspRestart<CR>", { desc = "LSP Restart" })

    map("n", "<leader>.", function()
      -- vim.cmd [[Lspsaga code_action]]
      require("actions-preview").code_actions()
    end, { desc = "󰅱 Code Action" })

    map("n", "<leader>gf", "<cmd>Lspsaga finder<cr>", { desc = "Lspsaga Finder" })
    map("n", "gd", "<cmd>Lspsaga goto_definition<cr>", { desc = " Go to definition" })
    map("n", "<leader>p", "<cmd>Lspsaga peek_definition<cr>", { desc = " Peek definition" })
    map("n", "gh", function()
      vim.cmd [[Lspsaga hover_doc]]
    end, { desc = "󱙼 Hover Docs" })

    map("n", "gI", "<CMD>Lspsaga incoming_calls<CR>", { desc = "Lspsaga incoming calls" })
    map("n", "gO", "<CMD>Lspsaga outgoing_calls<CR>", { desc = "Lspsaga outgoing calls" })
    map("n", "go", "<CMD>Lspsaga outline<CR>", { desc = " Show Outline" })
    map("n", "[d", "<CMD>Lspsaga diagnostic_jump_prev<CR>", { desc = " Prev Diagnostic" })
    map("n", "]d", "<CMD>Lspsaga diagnostic_jump_next<CR>", { desc = " Next Diagnostic" })
  end,
})
