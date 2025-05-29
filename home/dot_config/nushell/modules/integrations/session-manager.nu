# Session Manager for Nushell (Zellij & TMux)
# Author: walkeratmind
# Created: 2025-05-27
# Updated: 2025-05-29 07:18:21
# Description: Universal session management with FZF integration for both Zellij and TMux

# Module metadata
export const SESSION_MANAGER_INFO = {
    name: "session-manager"
    version: "3.1.0"
    author: "walkeratmind"
    created: "2025-05-27"
    updated: "2025-05-29 07:18:21"
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

# Core functionality - DRY principle
def "detect-multiplexer" [--preferred: string] {
    let current = (multiplexer detect)
    
    if $current != "none" { return $current }
    
    if ($preferred | is-not-empty) and (tool exists $preferred) {
        return $preferred
    }
    
    # Prefer zellij over tmux if both available
    if (tool exists "zellij") { "zellij" } else if (tool exists "tmux") { "tmux" } else { "none" }
}

# Unified session retrieval - single source of truth
def "get-sessions" [mux: string] {
    match $mux {
        "zellij" => { get-zellij-sessions }
        "tmux" => { get-tmux-sessions }
        _ => { [] }
    }
}

# Zellij session retrieval
def "get-zellij-sessions" [] {
    let result = (^zellij list-sessions --no-formatting 2>/dev/null | complete)
    
    if $result.exit_code != 0 { return [] }
    
    $result.stdout 
    | lines 
    | each {|line| parse-zellij-session $line}
    | compact
    | where {|session| not ($session.name | str contains "EXITED")}
}

# TMux session retrieval
def "get-tmux-sessions" [] {
    let result = (^tmux list-sessions -F "#{session_name}:#{session_attached}:#{session_created}:#{session_windows}" 2>/dev/null | complete)
    
    if $result.exit_code != 0 { return [] }
    
    $result.stdout
    | lines
    | each {|line| parse-tmux-session $line}
    | compact
}

# Parse Zellij session line
def "parse-zellij-session" [line: string] {
    let clean_line = ($line | str trim)
    if ($clean_line | str length) == 0 or ($clean_line | str contains "EXITED") {
        return null
    }
    
    # Try parsing with [Created] format first
    let created_match = ($clean_line | parse -r '^([^\s]+)\s+\[Created\s+([^\]]+)\]\s*(.*)?$')
    if ($created_match | length) > 0 {
        let session_data = ($created_match | first)
        let is_current = ($session_data.capture2? | default "" | str contains "current")
        {
            name: $session_data.capture0
            created: $session_data.capture1
            is_current: $is_current
            status: (if $is_current { "current" } else { "detached" })
            indicator: (if $is_current { "🟢" } else { "⚪" })
        }
    } else {
        # Fallback to simple session name parsing
        let name_match = ($clean_line | parse -r '^([^\s]+)')
        if ($name_match | length) > 0 {
            let session_name = ($name_match | first | get capture0)
            let is_current = ($clean_line | str contains "(current)")
            {
                name: $session_name
                created: "unknown"
                is_current: $is_current
                status: (if $is_current { "current" } else { "detached" })
                indicator: (if $is_current { "🟢" } else { "⚪" })
            }
        } else {
            null
        }
    }
}

# Parse TMux session line
def "parse-tmux-session" [line: string] {
    let parts = ($line | split column ":")
    if ($parts | length) < 2 { return null }
    
    let attached = ($parts | get column1) == "1"
    {
        name: ($parts | get column0)
        created: ($parts | get column2? | default "unknown")
        windows: ($parts | get column3? | default "1")
        status: (if $attached { "attached" } else { "detached" })
        is_current: $attached
        indicator: (if $attached { "🟢" } else { "⚪" })
    }
}

# Session age calculation
def "get-session-age" [session_name: string, mux: string] {
    match $mux {
        "zellij" => { get-zellij-session-age $session_name }
        "tmux" => { get-tmux-session-age $session_name }
        _ => { 0 }
    }
}

def "get-zellij-session-age" [session_name: string] {
    let result = (^zellij list-sessions --no-formatting 2>/dev/null | complete)
    if $result.exit_code != 0 { return 0 }
    
    let session_lines = ($result.stdout | lines | where {|line| 
        let clean = (strip-ansi $line)
        ($clean | str starts-with $session_name)
    })
    
    if ($session_lines | length) == 0 { return 0 }
    
    let clean_line = (strip-ansi ($session_lines | first))
    if ($clean_line | str contains "day") {
        let days_match = ($clean_line | parse -r '(\d+)\s*day')
        if ($days_match | length) > 0 {
            ($days_match | first | get capture0 | into int)
        } else { 0 }
    } else { 0 }
}

def "get-tmux-session-age" [session_name: string] {
    let result = (^tmux list-sessions -F "#{session_name}:#{session_created}" 2>/dev/null | complete)
    if $result.exit_code != 0 { return 0 }
    
    let sessions = ($result.stdout | lines | where {|line| 
        ($line | str starts-with $session_name)
    })
    
    if ($sessions | length) == 0 { return 0 }
    
    try {
        let created_timestamp = ($sessions | first | split column ":" | get column2 | into int)
        let current_timestamp = (date now | format date "%s" | into int)
        let age_seconds = ($current_timestamp - $created_timestamp)
        ($age_seconds / 86400)
    } catch {
        0
    }
}

# Session operations
def "create-session" [name: string, mux: string] {
    print $"🆕 Creating new ($mux) session: ($name)"
    match $mux {
        "zellij" => { ^zellij --session $name }
        "tmux" => { 
            ^tmux new-session -d -s $name
            ^tmux attach-session -t $name
        }
        _ => { print "❌ Unsupported multiplexer" }
    }
}

def "switch-session" [name: string, mux: string] {
    print $"🔄 Switching to ($mux) session: ($name)"
    match $mux {
        "zellij" => { switch-zellij-session $name }
        "tmux" => { switch-tmux-session $name }
        _ => { print "❌ Unsupported multiplexer" }
    }
}

def "switch-zellij-session" [name: string] {
    let in_zellij = ($env.ZELLIJ? | default "" | str length) > 0
    
    if $in_zellij {
        try {
            ^zellij action switch-session $name
            print $"✅ Switched to session: ($name)"
        } catch {
            print $"❌ Failed to switch to session: ($name)"
            print "💡 Try manually: zellij attach ($name)"
        }
    } else {
        try {
            ^zellij attach $name
            print $"✅ Attached to session: ($name)"
        } catch {
            print $"❌ Failed to attach to session: ($name)"
        }
    }
}

def "switch-tmux-session" [name: string] {
    let in_tmux = ($env.TMUX? | default "" | str length) > 0
    
    if $in_tmux {
        try {
            ^tmux switch-client -t $name
            print $"✅ Switched to session: ($name)"
        } catch {
            print $"❌ Failed to switch to session: ($name)"
        }
    } else {
        try {
            ^tmux attach-session -t $name
            print $"✅ Attached to session: ($name)"
        } catch {
            print $"❌ Failed to attach to session: ($name)"
        }
    }
}

def "kill-session" [name: string, mux: string] {
    match $mux {
        "zellij" => { 
            try {
                ^zellij kill-session $name
                print $"✅ Session ($name) killed successfully"
            } catch {
                print $"❌ Failed to kill session: ($name)"
            }
        }
        "tmux" => { 
            try {
                ^tmux kill-session -t $name
                print $"✅ Session ($name) killed successfully"
            } catch {
                print $"❌ Failed to kill session: ($name)"
            }
        }
        _ => { print "❌ Unsupported multiplexer" }
    }
}

# Display formatting
def "format-session-display" [session: record, mux: string] {
    let base = $"($session.indicator) ($session.name)"
    match $mux {
        "zellij" => {
            if $session.created != "unknown" {
                $"($base) | Created ($session.created)"
            } else { $base }
        }
        "tmux" => {
            let windows_info = if ($session.windows? != null) { $" │ Windows: ($session.windows)" } else { "" }
            $"($base)($windows_info) │ Created: ($session.created)"
        }
        _ => { $base }
    }
}

# FZF execution with floating support
def "execute-fzf" [
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

# Extract session name from FZF result
def "extract-session-name" [result: string] {
    $result 
    | str replace '^[🟢⚪]\s+' '' 
    | str replace ' \|.*$' '' 
    | str replace ' \│.*$' '' 
    | str trim
}

# Main commands
export def "sm switch" [
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
    
    # Handle session creation
    if ($create | is-not-empty) {
        create-session $create $mux
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

# Backward compatibility
# export alias "zs" = sm
