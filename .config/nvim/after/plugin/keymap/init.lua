local Remap = require("souldust.keymap")
local nnoremap = Remap.nnoremap
local vnoremap = Remap.vnoremap
local inoremap = Remap.inoremap
local xnoremap = Remap.xnoremap
local nmap = Remap.nmap

nnoremap("<leader>pv", ":Ex<CR>")
nnoremap("<leader>u", ":UndotreeShow<CR>")

vnoremap("J", ":m '>+1<CR>gv=gv")
vnoremap("K", ":m '<-2<CR>gv=gv")

nnoremap("Y", "yg$")

-- Search mappings: These will make it so that going to the next one in a
-- search will center on the line it's found in.
nnoremap("n", "nzzzv")
nnoremap("N", "Nzzzv")

nnoremap("J", "mzJ`z")
nnoremap("<C-d>", "<C-d>zz")
nnoremap("<C-u>", "<C-u>zz")

-- greatest remap ever
xnoremap("<leader>p", "\"_dP")

-- next greatest remap ever : asbjornHaland
nnoremap("<leader>y", "\"+y")
vnoremap("<leader>y", "\"+y")
nmap("<leader>Y", "\"+Y")

nnoremap("<leader>d", "\"_d")
vnoremap("<leader>d", "\"_d")

vnoremap("<leader>d", "\"_d")

inoremap("<C-c>", "<Esc>")
nnoremap("<C-c>", ":noh<CR>", {silent = true})  -- no search highlight

nnoremap("Q", "<nop>")
nnoremap("<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

nnoremap("<C-k>", "<cmd>cnext<CR>zz")
nnoremap("<C-j>", "<cmd>cprev<CR>zz")
nnoremap("<leader>k", "<cmd>lnext<CR>zz")
nnoremap("<leader>j", "<cmd>lprev<CR>zz")

nnoremap("<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")
nnoremap("<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })


-- Split window
nnoremap ('<Leader>h', '<C-u>split<CR>')
nnoremap ('<Leader>v', '<C-u>vsplit<CR>')

-- Move window
nnoremap('<leader>n', '<C-w>w')
nnoremap('<leader>h', '<C-w>h')
nnoremap('<leader>j', '<C-w>j')
nnoremap('<leader>k', '<C-w>k')
nnoremap('<leader>l', '<C-w>l')

-- Resize window <w, a, s, d> game key
nnoremap('<leader>a', '<C-w><')
nnoremap('<leader>d', '<C-w>>')
nnoremap('<leader>w', '<C-w>+')
nnoremap('<leader>s', '<C-w>-')

-- tab
nnoremap('<C-Left>', ':tabprevious<CR>')
nnoremap('<C-Right>', ':tabnext<CR>')
nnoremap('<leader>tp', ':tabprevious<CR>')
nnoremap('<leader>tn', ':tabnext<CR>')
nnoremap('<leader>tt', ':tabnew<CR>')
