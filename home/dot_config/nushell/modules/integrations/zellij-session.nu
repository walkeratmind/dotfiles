# Zellij Session Manager for Nushell
# Author: walkeratmind
# Created: 2025-05-27
# Updated: 2025-05-28 05:58:45
# Description: Dedicated zellij session management with FZF integration

# Module metadata
export const SESSION_MANAGER_INFO = {
    name: "zellij-session-manager"
    version: "2.4.2"
    author: "walkeratmind"
    created: "2025-05-27"
    updated: "2025-05-28 05:58:45"
    description: "Zellij session management with FZF integration"
    dependencies: ["fzf", "zellij"]
    optional_deps: ["bat"]
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

# Get sessions list with proper parsing
def "get-sessions" [mux: string] {
    match $mux {
        "zellij" => {
            let raw_output = (^zellij list-sessions --no-formatting | complete)
            
            if $raw_output.exit_code != 0 {
                return []
            }
            
            $raw_output.stdout 
            | lines 
            | each {|line| parse-session-line $line "zellij"}
            | compact
            | where {|session| not ($session.name | str contains "EXITED")}
        }
        "tmux" => {
            let sessions_raw = (^tmux list-sessions -F "#{session_name}:#{session_attached}:#{session_created}" 2>/dev/null | complete)
            
            if $sessions_raw.exit_code != 0 {
                return []
            }
            
            $sessions_raw.stdout
            | lines
            | each {|line| 
                let parts = ($line | split column ":")
                if ($parts | length) >= 3 {
                    let attached = ($parts | get column1) == "1"
                    {
                        name: ($parts | get column0)
                        created: ($parts | get column2)
                        status: (if $attached { "attached" } else { "detached" })
                        is_current: $attached
                        indicator: (if $attached { "🟢" } else { "⚪" })
                    }
                } else { null }
            }
            | compact
        }
        _ => { [] }
    }
}

# Get session creation time for cleanup functionality
def "get-session-age" [session_name: string] {
    let mux = (multiplexer detect)
    
    match $mux {
        "zellij" => {
            # Parse session creation time from zellij list-sessions output
            let raw_output = (^zellij list-sessions --no-formatting | complete)
            if $raw_output.exit_code == 0 {
                let session_lines = ($raw_output.stdout | lines | where {|line| 
                    let clean = (strip-ansi $line)
                    ($clean | str starts-with $session_name)
                })
                
                if ($session_lines | length) > 0 {
                    let session_line = ($session_lines | first)
                    let clean_line = (strip-ansi $session_line)
                    
                    # Extract time information (this is approximate)
                    if ($clean_line | str contains "day") {
                        let days_match = ($clean_line | parse -r '(\d+)day')
                        if ($days_match | length) > 0 {
                            ($days_match | first | get capture0 | into int)
                        } else { 0 }
                    } else if ($clean_line | str contains "h") {
                        0  # Less than a day
                    } else {
                        0  # Very recent
                    }
                } else {
                    0
                }
            } else {
                0
            }
        }
        "tmux" => {
            # TMux has better session time tracking
            let session_info = (^tmux list-sessions -F "#{session_name}:#{session_created}" | lines | where {|line| 
                ($line | str starts-with $session_name)
            })
            
            if ($session_info | length) > 0 {
                let created_timestamp = ($session_info | first | split column ":" | get column2 | into int)
                let current_timestamp = (date now | format date "%s" | into int)
                let age_seconds = ($current_timestamp - $created_timestamp)
                ($age_seconds / 86400)  # Convert to days
            } else {
                0
            }
        }
        _ => { 0 }
    }
}

# Zellij execution helper with corrected append syntax
def "exec-zellij" [
    command: string
    --floating(-f)
    --in-place(-i)
    --keep(-k)
    --name(-n): string
] {
    mut args = ["run"]
    
    if ($name | is-not-empty) { 
        $args = ($args | append ["--name", $name])
    }
    if $floating { 
        $args = ($args | append ["--floating", "--width", "100", "--height", "30"])
    }
    if $in_place { 
        $args = ($args | append "--in-place") 
    }
    if not $keep { 
        $args = ($args | append "--close-on-exit") 
    }
    
    $args = ($args | append ["--", "bash", "-c", $command])
    
    ^zellij ...$args
}

# TMux execution helper
def "exec-tmux" [
    command: string
    --floating(-f)
    --name(-n): string
] {
    mut args = ["new-window"]
    
    if ($name | is-not-empty) { 
        $args = ($args | append ["-n", $name])
    }
    $args = ($args | append ["bash", "-c", $command])
    
    ^tmux ...$args
}

# Enhanced session switcher with proper zellij commands
export def "zs switch" [
    --floating(-f)            # Run in floating pane
    --large(-l)               # Use large floating pane  
    --preview(-p)             # Show session preview
    --create(-c): string      # Create new session with name
] {
    # Set defaults based on flag presence
    let use_floating = $floating or ($floating == null and true)  # Default to true
    let use_large = $large or false
    let use_preview = $preview or ($preview == null and true)     # Default to true
    
    # Handle session creation
    if ($create | is-not-empty) {
        print $"🆕 Creating new zellij session: ($create)"
        ^zellij --session $create
        return
    }
    
    # Get zellij sessions
    let raw_output = (^zellij list-sessions --no-formatting | complete)
    
    if $raw_output.exit_code != 0 {
        print "❌ Failed to get zellij sessions"
        return
    }
    
    # Parse sessions - handle both formats (with and without [Created] info)
    let sessions = ($raw_output.stdout 
        | lines 
        | each { |line|
            let clean_line = ($line | str trim)
            if ($clean_line | str length) == 0 or ($clean_line | str contains "EXITED") {
                null
            } else {
                # Try to parse with [Created] format first
                let created_match = ($clean_line | parse -r '^([^\s]+)\s+\[Created\s+([^\]]+)\]\s*(.*)?$')
                if ($created_match | length) > 0 {
                    let session_data = ($created_match | first)
                    let is_current = ($session_data.capture2? | default "" | str contains "current")
                    {
                        name: $session_data.capture0
                        created: $session_data.capture1
                        is_current: $is_current
                    }
                } else {
                    # Fallback to simple session name parsing
                    let name_match = ($clean_line | parse -r '^([^\s]+)')
                    if ($name_match | length) > 0 {
                        let session_name = ($name_match | first | get capture0)
                        {
                            name: $session_name
                            created: "unknown"
                            is_current: false
                        }
                    } else {
                        null
                    }
                }
            }
        } 
        | compact
    )
    
    if ($sessions | length) == 0 {
        print "❌ No active zellij sessions found"
        print "💡 Use 'zs switch --create <name>' to create a new session"
        return
    }
    
    # Create display list for fzf
    let display_list = ($sessions | each {|session|
        let indicator = if $session.is_current { "🟢" } else { "⚪" }
        let created_info = if $session.created != "unknown" { $" | Created ($session.created)" } else { "" }
        $"($indicator) ($session.name)($created_info)"
    })
    
    # Save to temp file
    let temp_file = $"($env.XDG_CACHE_HOME)/zellij_sessions_(random chars -l 8).txt"
    $display_list | save $temp_file
    
    # Create the fzf script with proper bash syntax
    let script_file = $"($env.XDG_CACHE_HOME)/zellij_fzf_(random chars -l 8).sh"
    
    # Build script content as proper bash commands
    let script_lines = [
        "#!/bin/bash"
        "set -e"
        ""
        $"SESSIONS_FILE='($temp_file)'"
        ""
        "if [[ ! -f \"$SESSIONS_FILE\" ]]; then"
        "    echo 'Error: Sessions file not found'"
        "    exit 1"
        "fi"
        ""
        "# Run fzf with proper bash syntax"
        "cat \"$SESSIONS_FILE\" | fzf \\"
        $"    --height=($SESSION_CONFIG.session_height) \\"
        "    --layout=reverse \\"
        "    --border=rounded \\"
        "    --margin=2% \\"
        "    --padding=1 \\"
        "    --prompt='Select Session: ' \\"
        "    --header='Enter: Switch, Ctrl-C: Cancel, Ctrl-N: New, Ctrl-D: Delete' \\"
        "    --bind='ctrl-n:execute(echo __CREATE_NEW__)' \\"
        "    --bind='ctrl-d:execute(echo __DELETE__)'"
    ]
    
    # Add preview if enabled
    let final_script_lines = if $use_preview {
        $script_lines ++ [
            $"    --preview-window=right:($SESSION_CONFIG.preview_size):wrap \\"
            "    --preview='echo \"Session: {}\"; echo \"Status: Active\"; echo \"Type: Zellij\"'"
        ]
    } else {
        $script_lines
    }
    
    # Join all lines and remove trailing backslash from last line
    let script_content = ($final_script_lines | str join "\n" | str replace '\\\n$' '\n')
    
    $script_content | save $script_file
    chmod +x $script_file
    
    # Execute fzf
    let result = if $use_floating and (which zellij | length) > 0 {
        # Try to run in floating pane if we're in zellij
        try {
            let width = if $use_large { "120" } else { "100" }
            let height = if $use_large { "40" } else { "30" }
            
            ^zellij run --floating --width $width --height $height --close-on-exit -- bash $script_file | str trim
        } catch {
            # Fallback to regular execution
            bash $script_file | str trim
        }
    } else {
        bash $script_file | str trim
    }
    
    # Cleanup
    rm -f $script_file $temp_file
    
    # Handle the result
    if ($result | str contains "__CREATE_NEW__") {
        print "🆕 Creating new session..."
        let new_name = (input "Enter session name: ")
        if ($new_name | str length) > 0 {
            ^zellij --session $new_name
        }
    } else if ($result | str contains "__DELETE__") {
        # Extract session name from result
        let session_name = ($result | str replace '^[🟢⚪]\s+' '' | str replace ' \|.*$' '' | str trim)
        if ($session_name | str length) > 0 {
            print $"💀 Removing session: ($session_name)"
            try {
                ^zellij kill-session $session_name
                print $"✅ Session ($session_name) killed successfully"
            } catch {
                print $"❌ Failed to kill session: ($session_name)"
            }
        }
    } else if ($result | is-not-empty) {
        # Extract session name from result
        let session_name = ($result | str replace '^[🟢⚪]\s+' '' | str replace ' \|.*$' '' | str trim)
        
        if ($session_name | str length) > 0 {
            print $"🔄 Switching to session: ($session_name)"
            
            # Check if we're currently in a zellij session
            let in_zellij = ($env.ZELLIJ? | default "" | str length) > 0
            
            if $in_zellij {
                # Try different zellij actions for switching sessions
                try {
                    ^zellij action switch-session $session_name
                    print $"✅ Switched to session: ($session_name)"
                } catch {
                    try {
                        ^zellij action go-to-tab-name $session_name
                        print $"✅ Switched to tab: ($session_name)"
                    } catch {
                        print $"❌ Failed to switch to session: ($session_name)"
                        print "💡 Try manually: zellij attach ($session_name)"
                    }
                }
            } else {
                # Not in zellij, so attach to the session
                try {
                    ^zellij attach $session_name
                    print $"✅ Attached to session: ($session_name)"
                } catch {
                    print $"❌ Failed to attach to session: ($session_name)"
                }
            }
        } else {
            print "❌ Could not extract session name from selection"
        }
    }
}

# Quick session switcher for keybinding
export def "zs quick" [] {
    zs switch --floating --large --preview
}

# Create new session
export def "zs new" [name?: string] {
    let session_name = if ($name | is-empty) {
        input "Enter session name: "
    } else {
        $name
    }
    
    if ($session_name | str length) > 0 {
        zs switch --create $session_name
    } else {
        print "❌ Session name cannot be empty"
    }
}


export def "zs kill" [
    --floating(-f)            # Run in floating pane
] {
    let use_floating = $floating or false  # Default to false for kill command
    
    let mux = (multiplexer detect)
    let sessions = (get-sessions $mux)
    
    if ($sessions | is-empty) {
        print "❌ No sessions to kill"
        return
    }
    
    let session_names = ($sessions | get name)
    let temp_file = $"($env.XDG_CACHE_HOME)/kill_sessions_(random chars -l 8).txt"
    $session_names | save $temp_file
    
    let fzf_opts = [
        $"--height=($SESSION_CONFIG.session_height)"
        "--layout=reverse"
        "--border=rounded"
        "--margin=2%"
        "--padding=1"
        "--prompt='💀 Kill Session: '"
        "--header='Space: Select │ Enter: Confirm │ Ctrl-C: Cancel'"
        "--multi"
    ] | str join " "
    
    let fzf_cmd = $"cat ($temp_file) | fzf ($fzf_opts)"
    
    let result = if $use_floating {
        if (multiplexer is-active) {
            let script_file = $"($env.XDG_CACHE_HOME)/kill_session_script_(random chars -l 8).sh"
            $"#!/bin/bash\n($fzf_cmd)" | save $script_file
            chmod +x $script_file
            
            let zellij_result = (
                ^zellij run --floating 
                --width "100" 
                --height "30" 
                --close-on-exit 
                -- bash $script_file 
                | str trim
            )
            
            rm -f $script_file $temp_file
            $zellij_result
        } else {
            let result = (bash -c $fzf_cmd)
            rm -f $temp_file
            $result
        }
    } else {
        let result = (bash -c $fzf_cmd)
        rm -f $temp_file
        $result
    }
    
    if ($result | is-not-empty) {
        let selected_sessions = ($result | lines)
        for session in $selected_sessions {
            print $"💀 Removing session: ($session)"
            match $mux {
                "zellij" => { 
                    try {
                        ^zellij kill-session $session
                        print $"✅ Session ($session) killed successfully"
                    } catch {
                        print $"❌ Failed to kill session: ($session)"
                    }
                }
                "tmux" => { 
                    try {
                        ^tmux kill-session -t $session
                        print $"✅ Session ($session) killed successfully"
                    } catch {
                        print $"❌ Failed to kill session: ($session)"
                    }
                }
                _ => { print "❌ Cannot kill session: unsupported multiplexer" }
            }
        }
    }
}


# Session cleanup for sessions older than specified days
export def "zs clean" [
    --days(-d): int = 7    # Days threshold (default: 7)
    --dry-run(-n)          # Show what would be cleaned without actually doing it
    --force(-f)            # Skip confirmation
] {
    let mux = (multiplexer detect)
    let sessions = (get-sessions $mux)

    let old_sessions = ($sessions | each {|session|
        let age = (get-session-age $session.name)
        if $age >= $days {
            $session | insert age_days $age
        } else { null }
    } | compact)
    
    if ($old_sessions | is-empty) {
        print $"✅ No ($mux) sessions older than ($days) days found"
        return
    }
    
    print $"🧹 Found ($old_sessions | length) sessions older than ($days) days:"
    $old_sessions | select name age_days | table
    
    if $dry_run {
        print "🔍 Dry run - no sessions were actually cleaned"
        return
    }
    
    let confirm = if $force { 
        "y" 
    } else { 
        input "Are you sure you want to clean these sessions? (y/N): "
    }
    
    if ($confirm | str downcase) == "y" {
        for session in $old_sessions {
            print $"🧹 Cleaning session: ($session.name) ($session.age_days) days old"
            match $mux {
                "zellij" => { ^zellij kill-session $session.name }
                "tmux" => { ^tmux kill-session -t $session.name }
                _ => { print "❌ Cannot clean session: unsupported multiplexer" }
            }
        }
        print $"✅ Cleaned ($old_sessions | length) sessions"
    } else {
        print "❌ Cleanup cancelled"
    }
}

# Session status overview
export def "zs status" [] {
    let mux = (multiplexer detect)
    let sessions = (get-sessions $mux)
    
    print $"🖥️  ($mux | str capitalize) Session Status"
    print "========================"
    
    if ($sessions | is-empty) {
        print $"❌ No ($mux) sessions found"
        return
    }
    
    print $"📊 Total active sessions: ($sessions | length)"
    for session in $sessions {
        let status_text = if $session.is_current { " (current)" } else { "" }
        print $"  ($session.indicator) ($session.name)($status_text)"
    }
}

# List all sessions in table format
export def "zs list" [] {
    let mux = (multiplexer detect)
    let sessions = (get-sessions $mux)
    
    if ($sessions | is-empty) {
        print $"❌ No ($mux) sessions found"
        return
    }
    
    $sessions | select name created status is_current
}
