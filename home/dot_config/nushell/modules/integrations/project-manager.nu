
export def "pm" [] {
  fd --type d --max-depth 3 --min-depth 1 . ~/project_lab --exec sh -c 'test -d "$1/.git" && echo "$1"' _ {} | sed 's|.*/project_lab/||' | fzf --preview 'eza --tree --level=1 --no-time --no-user --no-permissions --color=always --icons ~/project_lab/{}' --preview-window=right:70% --border --ansi
}
