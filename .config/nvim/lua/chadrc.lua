---@type ChadrcConfig
--- https://nvchad.com/docs/config/plugins/
local M = {}

M.base46 = {
  theme = "gruvchad",
  -- telescope = { style = "bordered" },
  hl_override = {
    ["@variable"] = { italic = true },
  },
}

-- M.ui = {
--   statusline = {
--     theme = "minimal",
--     separator_style = "round",
--   },
-- }

return M
