-- emacs bahavior: https://cmp.saghen.dev/recipes.html#emacs-behavior

-- EMacs style tab complection and cycle, best with ghost text
-- local has_words_before = function()
-- 	local col = vim.api.nvim_win_get_cursor(0)[2]
-- 	if col == 0 then
-- 		return false
-- 	end
-- 	local line = vim.api.nvim_get_current_line()
-- 	return line:sub(col, col):match("%s") == nil
-- end

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
			accept = {
				auto_brackets = { enabled = true },
			},

			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200, -- Slightly faster
				treesitter_highlighting = true,
				window = { border = "rounded" },
			},

			list = {
				selection = {
					preselect = true,
					auto_insert = false, -- Better for Emacs-style workflow
				},
			},

			ghost_text = {
				enabled = true,
				show_with_menu = true,
			},

			menu = {
				auto_show = function(ctx)
					-- Show menu automatically but only when it makes sense
					return ctx.mode ~= "cmdline" and has_words_before()
				end,

				cmdline_position = function()
					if vim.g.ui_cmdline_pos ~= nil then
						local pos = vim.g.ui_cmdline_pos
						return { pos[1] - 1, pos[2] }
					end
					local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
					return { vim.o.lines - height, 0 }
				end,

				draw = {
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

		-- Optimized keymap combining Emacs-style with modern UX
		keymap = {
			-- Show/hide completion
			["<C-k>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "hide", "fallback" },

			-- Accept completion
			["<CR>"] = { "accept", "fallback" },

			-- Emacs-style TAB behavior with smart fallback
			["<Tab>"] = {
				function(cmp)
					-- if cmp.is_visible() then
					-- 	return cmp.accept()
					-- end
					if has_words_before() then
						return cmp.insert_next()
					end
					-- return false
				end,
				"fallback",
			},

			["<S-Tab>"] = {
				function(cmp)
					-- if cmp.is_visible() then
					-- 	return cmp.select_prev()
					-- end
					if has_words_before() then
						return cmp.insert_prev()
					end
					-- return false
				end,
				"fallback",
			},

			["<Up>"] = { "select_prev", "fallback" },
			["<Down>"] = { "select_next", "fallback" },

			["<C-p>"] = { "select_prev", "fallback" },
			["<C-n>"] = { "select_next", "fallback" },

			-- Documentation scrolling
			["<C-u>"] = { "scroll_documentation_up", "fallback" },
			["<C-d>"] = { "scroll_documentation_down", "fallback" },

			-- Alternative accept keys for flexibility
			["<C-y>"] = { "accept", "fallback" }, -- Emacs-style accept
			["<C-Space>"] = { "show", "fallback" }, -- Manual trigger
		},

		-- Signature help
		signature = {
			enabled = true,
			window = { border = "rounded" },
		},

		-- Optimized sources configuration
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			providers = {
				lsp = {
					min_keyword_length = 2, -- Number of characters to trigger porvider
					score_offset = 0, -- Boost/penalize the score of the items
					-- Only show LSP items when they're likely relevant
					enabled = function()
						return vim.bo.buftype ~= "prompt"
					end,
				},
				path = {
					min_keyword_length = 0,
					-- Show path completions in strings and comments
					enabled = function()
						local line = vim.api.nvim_get_current_line()
						local col = vim.api.nvim_win_get_cursor(0)[2]
						local before_cursor = line:sub(1, col)
						return before_cursor:match("['\"`]") ~= nil or before_cursor:match("%.%./") ~= nil
					end,
				},
				snippets = {
					min_keyword_length = 2,
					score_offset = -1, -- Slightly lower priority than LSP
				},
				buffer = {
					min_keyword_length = 3, -- Balanced
					max_items = 8, -- More options
					-- Don't show buffer completions in very small or large buffers
					enabled = function()
						local line_count = vim.api.nvim_buf_line_count(0)
						return line_count > 5 or line_count < 1000
					end,
				},
			},

			-- Per-filetype source configuration
			per_filetype = {
				lua = { "lsp", "path", "snippets", "buffer" },
				-- Disable buffer completions in large files for performance
				-- javascript = function()
				-- 	if vim.api.nvim_buf_line_count(0) > 1000 then
				-- 		return { "lsp", "path", "snippets" }
				-- 	end
				-- 	return { "lsp", "path", "snippets", "buffer" }
				-- end,
			},
		},

		fuzzy = {
			implementation = "prefer_rust_with_warning",
			use_frecency = true,
			use_proximity = true,
		},
	},
}
