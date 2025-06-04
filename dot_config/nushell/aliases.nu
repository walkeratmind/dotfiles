
# ------------------------------------------------------------
# Aliases
# ------------------------------------------------------------

# Alias for project folder navigation
export alias plab = cd ($env.HOME | path join "project_lab")


# Essentials
export alias lg = lazygit

# zellij session list/switcher
# export alias sms = sm switch
export alias ss = sm switch
export alias sn = zf session-new
export alias sk = zf session-kill
export alias sl = zf session-list


# aliases for chezmoi
export alias ch = chezmoi
export alias chad = chezmoi add
export alias chap = chezmoi apply
export alias chd = chezmoi diff
export alias chda = chezmoi data
export alias chs = chezmoi status

# eza
export alias x = eza --icons
export alias xa = eza --icons --all
export alias xl	= eza --long
export alias xla = eza --long --all
export alias xt	= eza --icons --tree
export alias xta = eza --icons --tree --all

# bat
export alias b = bat
export alias bn = bat --number
export alias bnl = bat --number --line-range
export alias bp = bat --plain
export alias bpl = bat --plain --line-range
export alias bl = bat --line-range

# Neovim variants
export alias lv = with-env { NVIM_APPNAME: "nvim-lazy" } { nvim }

# export def nv [...paths] {
#     let config = (input list -p "Select Neovim config:" ["lazy", "kickstart", "nvchad", "astrovim", "lunarvim"])
#     with-env { NVIM_APPNAME: $"nvim-($config)" } { nvim ...$paths }
# }


