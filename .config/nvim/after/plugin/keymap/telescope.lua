local Remap = require("souldust.keymap")
local nnoremap = Remap.nnoremap

nnoremap("<C-p>", function()
  require('telescope.builtin').find_files()
end)

nnoremap("<leader>ps", function()
    require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})
end)
nnoremap("<Leader>pf", function()
    require('telescope.builtin').find_files()
end)
nnoremap("<Leader>;g", function()
    require('telescope.builtin').git_files()
end)

nnoremap("<leader>pw", function()
    require('telescope.builtin').grep_string { search = vim.fn.expand("<cword>") }
end)
nnoremap("<leader>pb", function()
    require('telescope.builtin').buffers()
end)

nnoremap(';;', function()
  require('telescope.builtin').resume()
end)
nnoremap(";f",  ":Telescope file_browser<CR>", { noremap = true })

nnoremap(";e", function()
  require('telescope.builtin').diagnostics()
end)

nnoremap("<leader>vh", function()
    require('telescope.builtin').help_tags()
end)

-- TODO: Fix this immediately
nnoremap("<leader>vwh", function()
    require('telescope.builtin').help_tags()
end)

nnoremap("<leader>vrc", function()
    require('souldust.telescope').search_dotfiles({ hidden = true })
end)

nnoremap("<leader>gb", function()
    require('souldust.telescope').git_branches()
end)
nnoremap("<leader>gw", function()
    require('telescope').extensions.git_worktree.git_worktrees()
end)
nnoremap("<leader>gm", function()
    require('telescope').extensions.git_worktree.create_git_worktree()
end)

-- nnoremap("<leader>sf", function()
--   require('souldust.telescope').file_explore()
-- end)

nnoremap("<leader>fb", ":Telescope file_browser<CR>", { noremap = true })
