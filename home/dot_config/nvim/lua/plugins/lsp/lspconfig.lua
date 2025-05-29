local on_attach = require("nvchad.configs.lspconfig").on_attach
-- local capabilities = require("nvchad.configs.lspconfig").capabilities
local capabilities = require("blink.cmp").get_lsp_capabilities(require("nvchad.configs.lspconfig").capabilities)

return {
	{
		"neovim/nvim-lspconfig",
		dependencies = { "saghen/blink.cmp" },
		config = function()
			-- load defaults from nvchad
			require("nvchad.configs.lspconfig").defaults()

			local lspconfig = require("lspconfig")
			local util = require("lspconfig/util")

			local present, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if present then
				capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
			end

			local ok, _ = pcall(require, "ufo")
			if ok then
				capabilities.textDocument.foldingRange = {
					dynamicRegistration = false,
					lineFoldingOnly = true,
				}
			end

			local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end

			lspconfig.gopls.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				cmd = { "gopls" },
				filetypes = { "go", "gomod", "gowork", "gotmpl" },
				root_dir = util.root_pattern("go.work", "go.mod", ".git"),
				settings = {
					gopls = {
						completeUnimported = true,
						usePlaceholders = true,
						analyses = {
							unusedparams = true,
						},
					},
				},
			})

			lspconfig.templ.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				cmd = { "templ", "lsp" },
				filetypes = { "templ" },
			})

			-- lspconfig.rust_analyzer.setup {
			--   on_attach = on_attach,
			--   capabilities = capabilities,
			--   filetypes = { "rust" },
			--   root_dir = util.root_pattern "Cargo.toml",
			--   settings = {
			--     ["rust-analyzer"] = {
			--       cargo = {
			--         allFeatures = true,
			--       },
			--     },
			--   },
			-- }

			lspconfig.ts_ls.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				init_options = {
					preferences = {
						disableSuggestions = true,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
			})

			-- setup htmx lsp from prime the agean https://github.com/ThePrimeagen/htmx-lsp/blob/master/client/vscode/README.md
			lspconfig.htmx.setup({})

			-- configure css server
			lspconfig["cssls"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- configure tailwindcss server
			lspconfig["tailwindcss"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- configure svelte server
			lspconfig["svelte"].setup({
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					on_attach(client, bufnr)

					vim.api.nvim_create_autocmd("BufWritePost", {
						pattern = { "*.js", "*.ts" },
						callback = function(ctx)
							if client.name == "svelte" then
								client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
							end
						end,
					})
				end,
			})

			-- configure prisma orm server
			lspconfig["prismals"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- configure graphql language server
			-- lspconfig["graphql"].setup {
			--   capabilities = capabilities,
			--   on_attach = on_attach,
			--   filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
			-- }

			-- configure emmet language server
			lspconfig["emmet_ls"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
			})

			-- configure python server
			lspconfig["pyright"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					pyright = {
						-- use ruff import
						disableOrganizeImports = true,
					},
					python = {
						analysis = {
							-- ignore all to use ruff
							ignore = { "*" },
						},
					},
				},
			})

			lspconfig["ruff"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					configurationPreferance = "fileSystemFirst",
					enable = true,
					organizeImports = true,
					fixAll = true,
					lint = {
						enable = true,
					},
				},
			})
			-- configure lua server (with special settings)
			lspconfig["lua_ls"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = { -- custom settings for lua
					Lua = {
						-- make the language server recognize "vim" global
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							-- make language server aware of runtime files
							library = {
								[vim.fn.expand("$VIMRUNTIME/lua")] = true,
								[vim.fn.stdpath("config") .. "/lua"] = true,
							},
						},
					},
				},
			})

			lspconfig.biome.setup({
				capabilities = capabilities,
				on_attach = on_attach,

				filetypes = {
					"astro",
					"css",
					"graphql",
					"javascript",
					"javascriptreact",
					"json",
					"jsonc",
					"svelte",
					"typescript",
					"typescript.tsx",
					"typescriptreact",
					"vue",
					"yml",
					"yaml",
				},
			})

			lspconfig.vale_ls.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				filetyypes = { "markdown", "text", "tex", "html" },
			})

			lspconfig.yamlls.setup({
				on_attach = on_attach,
				-- on_attach = function(client, bufnr)
				--   client.server_capabilities.diagnosticProvider = true
				-- end,
				capabilities = capabilities,
				flags = {
					debounce_text_changes = 200,
				},
				settings = {
					yaml = {
						format = {
							enable = true,
							bracketSpacing = true,
						},
						validate = true,
						completion = true,
						schemaStore = {
							-- url = "https://www.schemastore.org/api/json/catalog.json",
							url = "",
							enable = false,
						},
						schemas = {
							-- {
							--   name = "Taskfile config",
							--   description = "Taskfile files",
							--   fileMatch = {
							--     "Taskfile.yaml",
							--     "Taskfile.dist.yaml",
							--     "Taskfile.yml",
							--     "Taskfile.dist.yml",
							--   },
							--   url = "https://taskfile.dev/schema.json",
							-- },

							["https://taskfile.dev/schema.json"] = {
								"**/Taskfile.yml",
								"**/Taskfile.yaml",
							},

							["https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.0/schema.yaml"] = {
								"**/openapi.{yaml,yml}",
							},
							["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
							--   ["../path/relative/to/file.yml"] = "/.github/workflows/*",
							--   ["/path/from/root/of/project"] = "/.github/workflows/*",
						},
					},
				},
			})

			lspconfig.sqls.setup({
				capabilities = capabilities,
				on_attach = on_attach,

				filetypes = {
					"sql",
					"mysql",
				},
			})

			lspconfig.nushell.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- -- disable by default for goto definition by split , only by command
			-- vim.lsp.handlers["textDocument/definition"] = goto_definition "split"

			local function goto_definition(split_cmd)
				local util = vim.lsp.util
				local log = require("vim.lsp.log")
				local api = vim.api

				-- note, this handler style is for neovim 0.5.1/0.6, if on 0.5, call with function(_, method, result)
				local handler = function(_, result, ctx)
					if result == nil or vim.tbl_isempty(result) then
						local _ = log.info() and log.info(ctx.method, "No location found")
						return nil
					end

					if split_cmd then
						vim.cmd(split_cmd)
					end

					if vim.tbl_islist(result) then
						util.jump_to_location(result[1])

						if #result > 1 then
							-- util.set_qflist(util.locations_to_items(result))
							vim.fn.setqflist(util.locations_to_items(result))
							api.nvim_command("copen")
							api.nvim_command("wincmd p")
						end
					else
						util.jump_to_location(result)
					end
				end

				return handler
			end
		end,
	},
}
