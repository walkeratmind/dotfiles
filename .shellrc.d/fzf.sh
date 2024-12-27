#!/bin/bash

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Fzf theme
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
-m \
--color=fg:#c0caf5,bg:#1a1b26,hl:#ff9e64 \
--color=fg+:#c0caf5,bg+:#292e42,hl+:#ff9e64 \
--color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff \
--color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a"

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# use rg instead of fd
# export FZF_DEFAULT_COMMAND='rg --files --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo $'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}

# fcd: Fuzzy change directory (converted from fish to zsh)
fcd () {
    local searchdir destdir tmpfile
    if [[ -n "$1" ]]; then
        searchdir="$1"
    else
        searchdir="$HOME"
    fi

    tmpfile=$(mktemp)
    find "$searchdir" \( ! -regex '.*/\..*' \) ! -name __pycache__ -type d | fzf > "$tmpfile"
    destdir=$(cat "$tmpfile")
    rm -f "$tmpfile"

    if [[ -z "$destdir" ]]; then
        return 1
    fi

    cd "$destdir" || return 1
}

# fkill: Fuzzy kill (converted from fish to zsh)
fkill () {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

    if [[ -n "$pid" ]]; then
        echo "$pid" | xargs kill -9
    fi
}

rgf () {
  # rg --color=always --line-number --no-heading --smart-case "${*:-}" |
  # fzf -m --ansi \
  #     --color "hl:-1:underline,hl+:-1:underline:reverse" \
  #     --delimiter : \
  #     --preview 'bat --color=always {1} --highlight-line {2}' \
  #     --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
  #     --bind 'enter:become(nvim {1} +{2})'
  #
  # 1. Search for text in files using Ripgrep
# 2. Interactively restart Ripgrep with reload action
# 3. Open the file in Vim
  RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
  INITIAL_QUERY="${*:-}"

  # Run fzf, capture the output line into selected_line
  selected_line="$(
    FZF_DEFAULT_COMMAND="$RG_PREFIX $(printf %q "$INITIAL_QUERY")" \
    fzf --ansi \
        --disabled --query "$INITIAL_QUERY" \
        --bind "change:reload:$RG_PREFIX {q} || true" \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'
  )"

  # Split selected_line by colon into file and line variables
  IFS=':' read -r file line <<< "$selected_line"

  [ -n "$file" ] && nvim "$file" "+${line}"
}
