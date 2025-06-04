# Session Manager for Nushell (Zellij & TMux)
# Author: walkeratmind
# Created: 2025-05-27
# Updated: 2025-05-29 07:46:25
# Description: Universal session management with FZF integration for both Zellij and TMux

# Module metadata
export const SESSION_MANAGER_INFO = {
    name: "session-manager"
    version: "3.1.2"
    author: "walkeratmind"
    created: "2025-05-27"
    updated: "2025-05-29 07:46:25"
    description: "Universal session management with FZF integration for Zellij and TMux"
    dependencies: ["fzf"]
    optional_deps: ["bat", "zellij", "tmux"]
}

# Configuration constants
export const SESSION_CONFIG = {
    session_height: "80%"
    session_width: "120"
    preview_size: "60%"
    border_style: "rounded"
    floating_margin: "5%"
    cleanup_days: 7
}

use session-utils.nu *

# FZF execution with floating support
export def "execute-fzf" [
    display_list: list<string>
    mux: string
    use_floating: bool = false
    use_large: bool = false
    use_preview: bool = true
] {
    # Create temp file
    let temp_file = $"($env.XDG_CACHE_HOME)/sessions_(random chars -l 8).txt"
    $display_list | save $temp_file
    
    # Build FZF command
    let fzf_lines = [
        "#!/bin/bash"
        "set -e"
        $"cat ($temp_file) | fzf \\"
        $"    --height=($SESSION_CONFIG.session_height) \\"
        "    --layout=reverse \\"
        "    --border=rounded \\"
        "    --margin=2% \\"
        "    --padding=1 \\"
        $"    --prompt='Select ($mux | str capitalize) Session: ' \\"
        "    --header='Enter: Switch │ Ctrl-N: New │ Ctrl-D: Delete │ Ctrl-C: Cancel' \\"
        "    --bind='ctrl-n:execute(echo __CREATE_NEW__)' \\"
        "    --bind='ctrl-d:execute(echo __DELETE__)'"
    ]
    
    let final_lines = if $use_preview {
        $fzf_lines ++ [
            $"    --preview-window=right:($SESSION_CONFIG.preview_size):wrap \\"
            $"    --preview='echo \"Session: {}\"; echo \"Multiplexer: ($mux)\"; echo \"Status: Active\"'"
        ]
    } else { $fzf_lines }
    
    let script_file = $"($env.XDG_CACHE_HOME)/fzf_script_(random chars -l 8).sh"
    ($final_lines | str join "\n" | str replace '\\\n$' '\n') | save $script_file
    chmod +x $script_file
    
    # Execute FZF
    let result = if $use_floating and (multiplexer is-active) {
        try {
            let width = if $use_large { "120" } else { "100" }
            let height = if $use_large { "40" } else { "30" }
            
            match $mux {
                "zellij" => {
                    ^zellij run --floating --width $width --height $height --close-on-exit -- bash $script_file | str trim
                }
                "tmux" => {
                    ^tmux display-popup -w $width -h $height -E "bash $script_file" | str trim
                }
                _ => { bash $script_file | str trim }
            }
        } catch {
            bash $script_file | str trim
        }
    } else {
        bash $script_file | str trim
    }
    
    # Cleanup
    cleanup-files [$script_file, $temp_file]
    $result
}


# Fixed test functions
# export def "sm debug-zellij" [] {
#     print "=== Debugging Zellij Sessions ==="
#     let result = (^zellij list-sessions --no-formatting | complete)
#     print $"Exit code: ($result.exit_code)"
#     print $"Stdout: '($result.stdout)'"
#     print $"Stderr: '($result.stderr)'"
#     
#     if $result.exit_code == 0 and ($result.stdout | str trim | str length) > 0 {
#         print "\n=== Raw Lines ==="
#         $result.stdout | lines | enumerate | each {|item| 
#             print $"Line ($item.index): '($item.item)'"
#         }
#         
#         print "\n=== Parsing Results ==="
#         let sessions = (get-zellij-sessions)
#         print $"Found ($sessions | length) sessions:"
#         if ($sessions | length) > 0 {
#             $sessions | table
#         }
#     } else {
#         print "No sessions found or command failed"
#     }
# }

# export def "sm debug-tmux" [] {
#     print "=== Debugging TMux Sessions (Standard) ==="
#     let result = (^tmux list-sessions | complete)
#     print $"Exit code: ($result.exit_code)"
#     print $"Stdout: '($result.stdout)'"
#     print $"Stderr: '($result.stderr)'"
#     
#     if $result.exit_code == 0 and ($result.stdout | str trim | str length) > 0 {
#         print "\n=== Raw Lines ==="
#         $result.stdout | lines | enumerate | each {|item| 
#             print $"Line ($item.index): '($item.item)'"
#         }
#         
#         print "\n=== Parsing Results ==="
#         let sessions = (get-tmux-sessions)
#         print $"Found ($sessions | length) sessions:"
#         if ($sessions | length) > 0 {
#             $sessions | table
#         }
#     } else {
#         print "No sessions found or command failed"
#         
#         # Try detailed format
#         print "\n=== Trying Detailed Format ==="
#         let detailed_result = (bash -c "tmux list-sessions -F '#{session_name}:#{session_attached}:#{session_created}:#{session_windows}'" | complete)
#         print $"Detailed Exit code: ($detailed_result.exit_code)"
#         print $"Detailed Stdout: '($detailed_result.stdout)'"
#         print $"Detailed Stderr: '($detailed_result.stderr)'"
#         
#         if $detailed_result.exit_code == 0 and ($detailed_result.stdout | str trim | str length) > 0 {
#             let detailed_sessions = (get-tmux-sessions-detailed)
#             print $"Found ($detailed_sessions | length) detailed sessions:"
#             if ($detailed_sessions | length) > 0 {
#                 $detailed_sessions | table
#             }
#         }
#     }
# }

# export def "sm debug-mux" [] {
#     let current = (multiplexer detect)
#     print $"Current multiplexer: ($current)"
#     print $"Zellij available: (tool exists 'zellij')"
#     print $"TMux available: (tool exists 'tmux')"
#     
#     if (tool exists "zellij") {
#         print "\n"
#         sm debug-zellij
#     }
#     
#     if (tool exists "tmux") {
#         print "\n"
#         sm debug-tmux
#     }
# }


# Main commands
export def "sm switch" [
    session_name?: string     # optinoal session name to switch
    --session(-s): string     # Alt flag for session name
    --floating(-f)            # Run in floating pane
    --large(-l)               # Use large floating pane  
    --preview(-p)             # Show session preview
    --create(-c): string      # Create new session with name
    --multiplexer(-m): string # Force specific multiplexer
] {
    let mux = if ($multiplexer | is-not-empty) { $multiplexer } else { detect-multiplexer }
    
    if $mux == "none" {
        print "❌ No supported multiplexer found (zellij or tmux)"
        return
    }
    
    # Handle session creation and switch
    if ($create | is-not-empty) {
        create-session $create $mux
        switch-session $create $mux
        return
    }

    # determine if session is provided for switch
    # prioritize for flag over positional 
    let target_session = if ($session | is-not-empty) {
      $session
    } else if ($session_name | is-not-empty) {
      $session_name
    } else {
      null
    }

    # if there's sesion name switch to it , skipping fzf sessions list
    if ($target_session | is-not-empty) {
      # let sessions = (get-sessions $mux)
      # let session_exists = ($sessions | where name == $target_session | length) > 0
      # if ($session_exists) {
      #   switch-session $target_session $mux
      # } else {
      #       print $"❌ Session '($target_session)' not found in ($mux)"
      #       print $"💡 Available sessions:"
      #       if ($sessions | length) > 0 {
      #           $sessions | select name status | table
      #       } else {
      #           print "   No sessions available"
      #       }
      #       print $"💡 Use 'sm new ($target_session)' to create it"
      # }
      switch-session $target_session $mux
      return
    }
    
    let sessions = (get-sessions $mux)
    
    if ($sessions | length) == 0 {
        print $"❌ No active ($mux) sessions found"
        print $"💡 Use 'sm switch --create <name>' or 'sm new <name>' to create a new session"
        return
    }
    
    # Set defaults
    let use_floating = $floating or ($floating == null and true)
    let use_large = $large or false
    let use_preview = $preview or ($preview == null and true)
    
    # Create display list
    let display_list = ($sessions | each {|session| format-session-display $session $mux})
    
    # Execute FZF
    let result = (execute-fzf $display_list $mux $use_floating $use_large $use_preview)
    
    # Handle result
    if ($result | str contains "__CREATE_NEW__") {
        let new_name = (input "Enter session name: ")
        if ($new_name | str length) > 0 {
            create-session $new_name $mux
        }
    } else if ($result | str contains "__DELETE__") {
        let session_name = (extract-session-name $result)
        if ($session_name | str length) > 0 {
            print $"💀 Removing session: ($session_name)"
            kill-session $session_name $mux
        }
    } else if ($result | is-not-empty) {
        let session_name = (extract-session-name $result)
        if ($session_name | str length) > 0 {
            switch-session $session_name $mux
        }
    }
}

export def "sm quick" [--multiplexer(-m): string] {
    sm switch --floating --large --preview --multiplexer $multiplexer
}

export def "sm new" [name?: string, --multiplexer(-m): string] {
    let mux = if ($multiplexer | is-not-empty) { $multiplexer } else { detect-multiplexer }
    
    if $mux == "none" {
        print "❌ No supported multiplexer found"
        return
    }
    
    let session_name = if ($name | is-empty) {
        input "Enter session name: "
    } else { $name }
    
    if ($session_name | str length) > 0 {
        create-session $session_name $mux
        
        switch-session $session_name $mux
    } else {
        print "❌ Session name cannot be empty"
    }
}

export def "sm kill" [
    --floating(-f)
    --multiplexer(-m): string
] {
    let mux = if ($multiplexer | is-not-empty) { $multiplexer } else { detect-multiplexer }
    
    if $mux == "none" {
        print "❌ No supported multiplexer found"
        return
    }
    
    let sessions = (get-sessions $mux)
    if ($sessions | is-empty) {
        print $"❌ No ($mux) sessions to kill"
        return
    }
    
    let temp_file = $"($env.XDG_CACHE_HOME)/kill_sessions_(random chars -l 8).txt"
    ($sessions | get name) | save $temp_file
    
    let fzf_cmd = $"cat ($temp_file) | fzf --height=80% --layout=reverse --border=rounded --margin=2% --padding=1 --prompt='💀 Kill ($mux | str capitalize) Session: ' --header='Space: Select │ Enter: Confirm │ Ctrl-C: Cancel' --multi"
    
    let result = if $floating and (multiplexer is-active) {
        let script_file = $"($env.XDG_CACHE_HOME)/kill_script_(random chars -l 8).sh"
        $"#!/bin/bash\n($fzf_cmd)" | save $script_file
        chmod +x $script_file
        
        let exec_result = match $mux {
            "zellij" => { ^zellij run --floating --width "100" --height "30" --close-on-exit -- bash $script_file | str trim }
            "tmux" => { ^tmux display-popup -w 100 -h 30 -E "bash $script_file" | str trim }
            _ => { bash $script_file | str trim }
        }
        
        cleanup-files [$script_file, $temp_file]
        $exec_result
    } else {
        let result = (bash -c $fzf_cmd)
        cleanup-files [$temp_file]
        $result
    }
    
    if ($result | is-not-empty) {
        let selected_sessions = ($result | lines)
        for session in $selected_sessions {
            print $"💀 Removing session: ($session)"
            kill-session $session $mux
        }
    }
}

export def "sm clean" [
    --days(-d): int = 7
    --dry-run(-n)
    --force(-f)
    --multiplexer(-m): string
] {
    let mux = if ($multiplexer | is-not-empty) { $multiplexer } else { detect-multiplexer }
    
    if $mux == "none" {
        print "❌ No supported multiplexer found"
        return
    }
    
    let sessions = (get-sessions $mux)
    let old_sessions = ($sessions | each {|session|
        let age = (get-session-age $session.name $mux)
        if $age >= $days {
            $session | insert age_days $age
        } else { null }
    } | compact)
    
    if ($old_sessions | is-empty) {
        print $"✅ No ($mux) sessions older than ($days) days found"
        return
    }
    
    print $"🧹 Found ($old_sessions | length) ($mux) sessions older than ($days) days:"
    $old_sessions | select name age_days | table
    
    if $dry_run {
        print "🔍 Dry run - no sessions were actually cleaned"
        return
    }
    
    let confirm = if $force { "y" } else { input "Are you sure you want to clean these sessions? (y/N): " }
    
    if ($confirm | str downcase) == "y" {
        for session in $old_sessions {
            print $"🧹 Cleaning session: ($session.name) ($session.age_days) days old"
            kill-session $session.name $mux
        }
        print $"✅ Cleaned ($old_sessions | length) sessions"
    } else {
        print "❌ Cleanup cancelled"
    }
}

export def "sm status" [--multiplexer(-m): string] {
    let mux = if ($multiplexer | is-not-empty) { $multiplexer } else { detect-multiplexer }
    
    if $mux == "none" {
        print "❌ No supported multiplexer found"
        return
    }
    
    let sessions = (get-sessions $mux)
    
    print $"🖥️  ($mux | str capitalize) Session Status"
    print "========================"
    
    if ($sessions | is-empty) {
        print $"❌ No ($mux) sessions found"
        print $"💡 Use 'sm new <name>' to create a new session"
        return
    }
    
    print $"📊 Total active sessions: ($sessions | length)"
    for session in $sessions {
        let status_text = if $session.is_current { " (current)" } else { "" }
        let windows_info = if ($session.windows? != null) { $" [($session.windows) windows]" } else { "" }
        print $"  ($session.indicator) ($session.name)($status_text)($windows_info)"
    }
}

export def "sm list" [--multiplexer(-m): string] {
    let mux = if ($multiplexer | is-not-empty) { $multiplexer } else { detect-multiplexer }
    
    if $mux == "none" {
        print "❌ No supported multiplexer found"
        return
    }
    
    let sessions = (get-sessions $mux)
    
    if ($sessions | is-empty) {
        print $"❌ No ($mux) sessions found"
        return
    }
    
    match $mux {
        "tmux" => { $sessions | select name created status is_current windows }
        _ => { $sessions | select name created status is_current }
    }
}

export def "sm info" [] {
    let current = (multiplexer detect)
    let has_zellij = (tool exists "zellij")
    let has_tmux = (tool exists "tmux")
    
    print "🔍 Session Manager Information"
    print "============================="
    print $"Current environment: ($current)"
    print $"Zellij available: ($has_zellij)"
    print $"TMux available: ($has_tmux)"
    
    if $current != "none" {
        print $"\n📊 Current ($current) sessions:"
        sm status --multiplexer $current
    } else {
        print "\n💡 No active multiplexer session. Use 'sm new <name>' to create a session."
    }
}

