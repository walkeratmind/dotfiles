
use session-utils.nu *

export def "pm" [] {
  let project_dir = ($env.HOME | path join "project_lab")

  let selected_dir = fd --type d --max-depth 3 --min-depth 1 . $project_dir --exec sh -c 'test -d "$1/.git" && echo "$1"' _ {} | sed 's|.*/project_lab/||' | fzf --preview 'eza --tree --level=1 --no-time --no-user --no-permissions --color=always --icons ~/project_lab/{}' --preview-window=right:70% --border --ansi --border-label '🛠️ Project Manager'

  let session_title =  ($selected_dir | split row "/" | last | str trim )
  echo $session_title

  # let exec_result = match $mux {
  #           "zellij" => { create-session $session_title $mux }
  #           "tmux" => { create-session $session_title $mux }
  #           _ => { cd ($project_dir | path join $selected_dir) }
  #       }

  # $exec_result

  let project_path = ($project_dir | path join $selected_dir)
  let mux = detect-multiplexer  

  if (zellij-has-session $session_title) {
    switch-session $session_title "zellij"
    return
  }

  if (tmux-has-session $session_title) {
    switch-session $session_title "tmux"
    return
  }

  if ($mux == "none" ) {
   ^cd $project_path 
   return
  } 

  # mux is present, then create and switch to respective mux
   create-session $session_title $mux -d $project_path
   switch-session $session_title $mux
  
}
