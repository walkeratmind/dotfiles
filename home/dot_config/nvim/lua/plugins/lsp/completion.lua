-- emacs bahavior: https://cmp.saghen.dev/recipes.html#emacs-behavior
-- local has_words_before = function()
-- 	local col = vim.api.nvim_win_get_cursor(0)[2]
-- 	if col == 0 then
-- 		return false
-- 	end
--
-- 	local line = vim.api.nvim_get_current_line():sub()
-- 	return line:sub(col, col):match("%s") == nil
-- end

-- EMacs style tab complection and cycle, best with ghost text
local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	if col == 0 then
		return false
	end
	local text = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
	return text:sub(col, col):match("%s") == nil
end

return {
	"saghen/blink.cmp",
	event = "InsertEnter",
	dependencies = {
		"rafamadriz/friendly-snippets",
		-- "onsails/lspkind.nvim",
	},
	version = "*",

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {

		appearance = {
			use_nvim_cmp_as_default = false,
			nerd_font_variant = "mono",
		},

		completion = {
			accept = { auto_brackets = { enabled = true } },

			documentation = {
				auto_show = true,
				auto_show_delay_ms = 250,
				treesitter_highlighting = true,
				window = { border = "rounded" },
			},

			list = {
				selection = {
					preselect = true,
					auto_insert = true,

					-- or a function
					-- preselect = function(ctx)
					--   return not require("blink.cmp").snippet_active { direction = 1 }
					-- end,
					-- auto_insert = function(ctx)
					--   return vim.bo.filetype ~= "markdown"
					-- end,
				},
			},

			ghost_text = { show_with_menu = true, enabled = true },
			menu = {
				auto_show = true,
				-- border = "rounded",

				cmdline_position = function()
					if vim.g.ui_cmdline_pos ~= nil then
						local pos = vim.g.ui_cmdline_pos -- (1, 0)-indexed
						return { pos[1] - 1, pos[2] }
					end
					local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
					return { vim.o.lines - height, 0 }
				end,

				draw = {
					-- columns = {
					--   { "kind_icon", "label", gap = 2 },
					--   { "kind" },
					-- },

					-- columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind", "source_name", gap = 2 } },
					columns = {
						{ "kind_icon", "label", "label_description", gap = 1 },
						{ "kind", "source_name", gap = 1 },
					},

					components = {
						kind_icon = {
							text = function(ctx)
								local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
								return kind_icon
							end,
							-- (optional) use highlights from mini.icons
							highlight = function(ctx)
								local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
								return hl
							end,
						},
						kind = {
							-- (optional) use highlights from mini.icons
							highlight = function(ctx)
								local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
								return hl
							end,
						},
						label = {
							width = { fill = true, max = 60 },
							text = function(ctx)
								return ctx.label .. ctx.label_detail
							end,
							highlight = function(ctx)
								-- label and label details
								local highlights = {
									{
										0,
										#ctx.label,
										group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel",
									},
								}
								if ctx.label_detail then
									table.insert(
										highlights,
										{ #ctx.label, #ctx.label + #ctx.label_detail, group = "BlinkCmpLabelDetail" }
									)
								end

								-- characters matched on the label by the fuzzy matcher
								for _, idx in ipairs(ctx.label_matched_indices) do
									table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
								end

								return highlights
							end,
						},
					},
				},
			},
		},

		-- My super-TAB configuration
		keymap = {
			["<C-k>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "hide", "fallback" },
			-- ["<CR>"] = { "accept", "fallback" },
			["<TAB>"] = { "accept", "fallback" },

			-- -- ["<Tab>"] = {
			-- --   function(cmp)
			-- --     return cmp.select_next()
			-- --   end,
			-- --   "snippet_forward",
			-- --   "fallback",
			-- -- },
			-- -- ["<S-Tab>"] = {
			-- --   function(cmp)
			-- --     return cmp.select_prev()
			-- --   end,
			-- --   "snippet_backward",
			-- --   "fallback",
			-- -- },
			--
			-- emacs style completion
			-- If completion hasn't been triggered yet, insert the first suggestion; if it has, cycle to the next suggestion.
			["<TAB>"] = {
				function(cmp)
					if has_words_before() then
						return cmp.insert_next()
					end
				end,
				"fallback",
			},
			-- Navigate to the previous suggestion or cancel completion if currently on the first one.
			["<S-Tab>"] = { "insert_prev" },

			["<Up>"] = { "select_prev", "fallback" },
			["<Down>"] = { "select_next", "fallback" },
			["<C-p>"] = { "select_prev", "fallback" },
			["<C-n>"] = { "select_next", "fallback" },
			["<C-u>"] = { "scroll_documentation_up", "fallback" },
			["<C-d>"] = { "scroll_documentation_down", "fallback" },
		},

		-- Experimental signature help support
		signature = {
			enabled = true,
			window = { border = "rounded" },
		},

		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			providers = {
				lsp = {
					min_keyword_length = 2, -- Number of characters to trigger porvider
					score_offset = 0, -- Boost/penalize the score of the items
				},
				path = {
					min_keyword_length = 0,
				},
				snippets = {
					min_keyword_length = 2,
				},
				buffer = {
					min_keyword_length = 5,
					max_items = 5,
				},
			},
		},

		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
}
