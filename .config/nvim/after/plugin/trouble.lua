
local Remap = require("souldust.keymap")
local nnoremap = Remap.nnoremap
local inoremap = Remap.inoremap

local status, plugin_config = pcall(require, "trouble")
if (not status) then return end

plugin_config.setup({

})

nnoremap("<leader>xx", "<cmd>TroubleToggle<cr>")
nnoremap("<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>")
nnoremap("<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>")
nnoremap("<leader>xq", "<cmd>TroubleToggle quickfix<cr>")
nnoremap("<leader>xl", "<cmd>TroubleToggle loclist<cr>")
nnoremap("gR", "<cmd>TroubleToggle lsp_references<cr>")
