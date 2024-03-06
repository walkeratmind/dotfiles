local Remap = require("souldust.keymap")
local nnoremap = Remap.nnoremap

nnoremap("<leader>fc", function()
    require('telescope.builtin').grep_string({ search = vim.fn.input("rg For > ")})
end)

nnoremap("<Leader>ff", function()
    require('telescope.builtin').find_files()
end)
nnoremap("<Leader>;g", function()
    require('telescope.builtin').git_files()
end)

nnoremap("<leader>fw", function()
    require('telescope.builtin').grep_string { search = vim.fn.expand("<cword>") }
end)
nnoremap("<leader>pb", function()
    require('telescope.builtin').buffers()
end)

nnoremap('<leader>fr', function()
  require('telescope.builtin').resume()
end)

nnoremap("<leader>fb", ":Telescope file_browser<CR>", { noremap = true })

nnoremap(";e", function()
  require('telescope.builtin').diagnostics()
end)

nnoremap("<leader>fh", function()
    require('telescope.builtin').help_tags()
end)

nnoremap("<leader>fsd", function()
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

nnoremap("<leader>sf", function()
  require('souldust.telescope').file_explore()
end)

