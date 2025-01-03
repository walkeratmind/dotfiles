return {
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = "mfussenegger/nvim-dap",
    config = function(_, opts)
      require("dap-go").setup(opts)
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    event = "LspAttach",
    config = function()
      -- local _, dapui = pcall(require, "dapui")
      local dapui = require "dapui"

      local dap = require "dap"
      local keymap = vim.keymap

      dapui.setup()

      keymap.set("n", "<leader>dd", dapui.toggle, { desc = "DapUI Toggle" })
      keymap.set("n", "<leader>dc", dapui.toggle, { desc = "DapUI Close" })
      keymap.set("n", "<leader>do", function()
        dapui.open()
        vim.cmd [[DapContinue]]
      end, { desc = "DapUI Open" })

      dap.listeners.before.event_initialized["dapui_config"] = function()
        local api = require "nvim-tree.api"
        local view = require "nvim-tree.view"
        if view.is_visible() then
          api.tree.close()
        end

        for _, winnr in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local bufnr = vim.api.nvim_win_get_buf(winnr)
          if vim.api.nvim_get_option_value("ft", { buf = bufnr }) == "dap-repl" then
            dapui.open()
            return
          end
        end
        -- dapui:open()
      end
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      vim.keymap.set("n", "<leader>d<space>", ":DapContinue<CR>")
      vim.keymap.set("n", "<leader>dl", ":DapStepInto<CR>")
      vim.keymap.set("n", "<leader>dj", ":DapStepOver<CR>")
      vim.keymap.set("n", "<leader>dh", ":DapStepOut<CR>")
      vim.keymap.set("n", "<leader>dz", ":ZoomWinTabToggle<CR>")
      vim.keymap.set(
        "n",
        "<leader>dgt", -- dg as in debu[g] [t]race
        ":lua require('dap').set_log_level('TRACE')<CR>"
      )
      vim.keymap.set(
        "n",
        "<leader>dge", -- dg as in debu[g] [e]dit
        function()
          vim.cmd(":edit " .. vim.fn.stdpath "cache" .. "/dap.log")
        end
      )
      vim.keymap.set("n", "<F1>", ":DapStepOut<CR>")
      vim.keymap.set("n", "<F2>", ":DapStepOver<CR>")
      vim.keymap.set("n", "<F3>", ":DapStepInto<CR>")
      vim.keymap.set("n", "<leader>dr", function()
        require("dap").restart()
      end)

      vim.keymap.set("n", "<leader>dt", function()
        require("dap").terminate()
        require("dapui").close()
      end)
    end,
  },
}
