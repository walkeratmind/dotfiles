vim.diagnostic.config {
  virtual_text = {
    severity = {
      max = vim.diagnostic.severity.WARN,
    },
  },
  virtual_lines = {
    severity = {
      min = vim.diagnostic.severity.ERROR,
    },
  },
}

local diag_config1 = {
  virtual_text = {
    severity = {
      max = vim.diagnostic.severity.WARN,
    },
  },
  virtual_lines = {
    severity = {
      min = vim.diagnostic.severity.ERROR,
    },
  },
}
local diag_config2 = {
  virtual_text = true,
  virtual_lines = false,
}
vim.diagnostic.config(diag_config1)
local diag_config_basic = false
vim.keymap.set("n", "gK", function()
  diag_config_basic = not diag_config_basic
  if diag_config_basic then
    vim.diagnostic.config(diag_config2)
  else
    vim.diagnostic.config(diag_config1)
  end
end, { desc = "Toggle diagnostic virtual_lines" })
