#!/bin/sh


alias v='nvim' # default Neovim config
alias nvim-lazy='NVIM_APPNAME=nvim-lazy nvim' # LazyVim
# alias vc='NVIM_APPNAME=nvim-nvchad nvim' # NvChad
alias nvim-kick='NVIM_APPNAME=nvim-kickstart nvim' # Kickstart
alias nvim-astro='NVIM_APPNAME=nvim-astrovim nvim' # AstroVim

function nvims() {
  # Assumes all configs exist in directories named ~/.config/nvim-*
  local config=$(fd --max-depth 1 --glob 'nvim-*' ~/.config | fzf --prompt="Neovim Configs > " --height=~50% --layout=reverse --border --exit-0)

  # If I exit fzf without selecting a config, don't open Neovim
  [[ -z $config ]] && echo "No config selected" && return

  # Open Neovim with the selected config
  NVIM_APPNAME=$(basename $config) nvim $@
}
