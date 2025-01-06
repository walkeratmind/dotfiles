local map = vim.keymap.set

require "nvchad.mappings"

map("n", ";", ":", { desc = "CMD enter command mode" })

-- map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move lines down" })
-- map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move lines up" })
-- map("v", "<A-j>", "<cmd>move+1<cr>gv=gv", { desc = "Move lines down" })
-- map("v", "<A-k>", "<cmd>move-2<cr>gv=gv", { desc = "Move lines up" })

map(
  "n",
  "<leader>qc",
  ":cclose | call setqflist([], 'r')<CR>",
  { desc = "Clear loclist", noremap = true, silent = true }
)

map(
  "n",
  "<leader>ql",
  ":lclose | call setloclist(0, [], 'r')<CR>",
  { desc = "Clear qflist", noremap = true, silent = true }
)

map("n", "<leader>fm", function()
  require("conform").format()
end, { desc = "File Format with conform" })

map("i", "jk", "<ESC>", { desc = "Escape insert mode" })

map("n", "gd", "<CMD>Lspsaga goto_definition<CR>", { desc = "Lspsaga goto definition" })
map("n", "<leader>k", "<CMD>Lspsaga hover_doc<CR>", { desc = "Lspsaga hover" })

-- unmap nvchad keymaps
map("n", "<leader>h", "<Nop>")
map("n", "<C-c>", "<nop>")
map("n", "gi", "<nop>")
map("n", "gd", "<nop>")

map("i", "<C-b>", "<ESC>^i", { desc = "Move Beginning of line" })
map("i", "<C-e>", "<End>", { desc = "Move End of line" })
map("i", "<C-h>", "<Left>", { desc = "Move Left" })
map("i", "<C-l>", "<Right>", { desc = "Move Right" })
map("i", "<C-j>", "<Down>", { desc = "Move Down" })
map("i", "<C-k>", "<Up>", { desc = "Move Up" })

map("n", "<C-c>", "<cmd>noh<CR>", { desc = "General Clear highlights" })

map("n", "<C-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", { desc = "Switch Window left" })
map("n", "<C-l>", "<cmd><C-U>TmuxNavigateRight<cr>", { desc = "Switch Window right" })
map("n", "<C-j>", "<cmd><C-U>TmuxNavigateDown<cr>", { desc = "Switch Window down" })
map("n", "<C-k>", "<cmd><C-U>TmuxNavigateUp<cr>", { desc = "Switch Window up" })

-- dap keymaps
map("n", "<leader>db", "<cmd> DapToggleBreakpoint <cr>", { desc = "Toggle Debugger Breakpoint" })
map("n", "<leader>dus", function()
  local widgets = require "dap.ui.widgets"
  local sidebar = widgets.sidebar(widgets.scopes)
  sidebar.open()
end, { desc = "Open debugging sidebar" })

-- Golang keymaps
map("n", "<leader>dgr", function()
  require("dap-go").debug_test()
end, { desc = "Debug go test" })
map("n", "<leader>dgl", function()
  require("dap-go").debug_last()
end, { desc = "Debug Last Go Test" })

map("n", "<leader>gsj", "<cmd> GoTagAdd json <cr>", { desc = "Add json struct tags" })
map("n", "<leader>gsy", "<cmd> DapToggleBreakpoint <cr>", { desc = "Add yaml struct tags" })

map("n", "<leader>pj", "<CMD>Portal jumplist backward<CR>", { desc = "󱡁 Portal Jumplist" })
map("n", "<leader>ph", function()
  require("portal.builtin").harpoon.tunnel()
end, { desc = "󱡁 Portal Harpoon" })

-- telescope keymaps
map("n", "<leader>fi", "<cmd>Telescope help_tags<cr>", { desc = "Telescope help tags" })
map("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", { desc = "Telescope Keymaps" })
map(
  "n",
  "<leader>fw",
  "<cmd>Telescope live_grep grep_command=rg,--ignore<CR>",
  { desc = "telescope live grep (includes hidden)" }
)
map(
  { "n", "v" },
  "<leader>ff",
  "<cmd>Telescope find_files find_command=rg,--ignore,--files,--sortr,accessed<CR>",
  { desc = "telescope find files" }
)

map(
  { "n", "v" },
  "<leader>fb",
  ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
  { desc = "Telescope File Browser" }
)

-- map("n", "<C-m>", "<cmd>Telescope marks<cr>", { desc = "Telescope Marks" })

-- Harpoon
local harpoon = require "harpoon"
-- Toggle previous & next buffers stored within Harpoon list
map("n", "<C-h>", function()
  harpoon:list():prev()
end, { desc = "Harpoon Previous" })
map("n", "<C-l>", function()
  harpoon:list():next()
end, { desc = "Harpooon Next" })

-- Refactoring
require("telescope").load_extension "refactoring"
map("n", "<leader>rf", function()
  require("telescope").extensions.refactoring.refactors()
end, { desc = "Telescope Refactoring" })
map("n", "<leader>rr", function()
  require("refactoring").select_refactor()
end, { desc = "Toggle Refactoring" })
