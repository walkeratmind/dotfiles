local map = vim.keymap.set

local plugins = {

  -- {
  --   "letieu/harpoon-lualine",
  --   dependencies = {
  --     {
  --       "ThePrimeagen/harpoon",
  --       branch = "harpoon2",
  --     },
  --   },
  -- },

  {
    "NvChad/nvterm",
    enabled = false,
  },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {}, enabled = false },
}

return plugins
