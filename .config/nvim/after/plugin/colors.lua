vim.g.colorscheme = "gruvbox"

function ColorMyPencils()

    -- highlight and appearance

    vim.cmd("colorscheme " .. vim.g.colorscheme)
    vim.g.gruvbox_contrast_dark = 'hard'
    vim.g.tokyonight_transparent_sidebar = true
    vim.g.tokyonight_transparent = true
    vim.g.gruvbox_invert_selection = '0'

    vim.g.tokyonight_style = "night"
    vim.g.tokyonight_italic_functions = true
    vim.g.tokyonight_transparent = true
    vim.g.tokyonight_transparent_sidebar = true


    vim.opt.cursorline = true
    vim.opt.termguicolors = true
    vim.opt.winblend = 0
    vim.opt.wildoptions = 'pum'
    vim.opt.pumblend = 5
    vim.opt.background = 'dark'
    -- vim.cmd[[&t_Co = 256]]

    local hl = function(thing, opts)
        vim.api.nvim_set_hl(0, thing, opts)
    end

    hl("SignColumn", {
        bg = "none",
    })

    hl("ColorColumn", {
        ctermbg = 0,
        bg = "#555555",
    })

    hl("CursorLineNR", {
        bg = "None"
    })

    hl("Normal", {
        bg = "none"
    })

    hl("LineNr", {
        fg = "#5eacd3"
    })

    hl("netrwDir", {
        fg = "#5eacd3"
    })

end
ColorMyPencils()
