# Zellij Session Manager for Nushell
# Author: walkeratmind
# Created: 2025-05-27
# Updated: 2025-05-27 14:43:40
# Description: Dedicated zellij session management with FZF integration

# Module metadata
export const SESSION_MANAGER_INFO = {
    name: "zellij-session-manager"
    version: "2.4.1"
    author: "walkeratmind"
    created: "2025-05-27"
    updated: "2025-05-27 14:43:40"
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

# Multiplexer detection
export def "multiplexer detect" [] {
    if ($env.ZELLIJ? != null) {
        "zellij"
    } else if ($env.TMUX? != null) {
        "tmux"
    } else {
        "none"
    }
}

export def "multiplexer is-active" [] {
    (multiplexer detect) != "none"
}

# Tool detection
export def "tool exists" [name: string] {
    not (which $name | is-empty)
}

# Strip ANSI codes from text
def "strip-ansi" [text: string] {
    $text | str replace -a '\x1b\[[0-9;]*[mK]' '' | str replace -a '\x1b\[' ''
}

# Get session creation time for cleanup functionality - FIXED
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

# FIXED: Zellij execution helper with corrected append syntax
def "exec-zellij" [
    command: string
    --floating(-f)
    --in-place(-i)
    --keep(-k)
    --name(-n): string
] {
    mut args = ["run"]
    
    if ($name | is-not-empty) { 
        $args = ($args | append "--name")
        $args = ($args | append $name)
    }
    if $floating { 
        $args = ($args | append "--floating")
        # FIXED: Append arguments one at a time
        $args = ($args | append "--width")
        $args = ($args | append "100")
        $args = ($args | append "--height")
        $args = ($args | append "30")
    }
    if $in_place { $args = ($args | append "--in-place") }
    if not $keep { $args = ($args | append "--close-on-exit") }
    
    # FIXED: Append multiple arguments correctly
    $args = ($args | append "--")
    $args = ($args | append "bash")
    $args = ($args | append "-c")
    $args = ($args | append $command)
    
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
        $args = ($args | append "-n")
        $args = ($args | append $name)
    }
    $args = ($args | append "bash")
    $args = ($args | append "-c")
    $args = ($args | append $command)
    
    ^tmux ...$args
}

# Enhanced session switcher with proper zellij commands
export def "zs switch" [
    --floating(-f)         # Run in floating pane (default: true for better UX)
    --large(-l)            # Use large floating pane
    --preview(-p)          # Show session preview (default: true)
    --create(-c): string   # Create new session with name
] {
    let use_floating = $floating != false  # Default to floating unless explicitly disabled
    let use_preview = $preview != false    # Default to preview unless explicitly disabled
    let use_large = $large or $use_floating  # Large pane if floating or explicitly requested
    
    # Handle session creation
    if ($create | is-not-empty) {
        let mux = (multiplexer detect)
        match $mux {
            "zellij" => {
                print $"🆕 Creating new zellij session: ($create)"
                ^zellij --session $create
                return
            }
            "tmux" => {
                print $"🆕 Creating new tmux session: ($create)"
                ^tmux new-session -d -s $create
                ^tmux attach-session -t $create
                return
            }
            _ => {
                print "❌ No terminal multiplexer detected"
                return
            }
        }
    }
    
    let mux = (multiplexer detect)
    
    match $mux {
        "zellij" => {
            # Get session information with better formatting
            let raw_output = (^zellij list-sessions --no-formatting | complete)
            
            if $raw_output.exit_code != 0 {
                print "❌ Failed to get zellij sessions"
                return
            }
            
            # Parse session information more comprehensively
            let sessions_info = ($raw_output.stdout 
                | lines 
                | each { |line|
                    let clean_line = (strip-ansi $line | str trim)
                    if ($clean_line | str length) == 0 or ($clean_line | str contains "EXITED") {
                        null
                    } else {
                        # Extract session name and metadata
                        let parts = ($clean_line | parse -r '^([^\s]+)\s+\[Created\s+([^\]]+)\]\s*(.*)?$')
                        if ($parts | length) > 0 {
                            let session_data = ($parts | first)
                            let is_current = ($session_data.capture2? | default "" | str contains "current")
                            let status_indicator = if $is_current { "🟢" } else { "⚪" }
                            {
                                name: $session_data.capture0
                                created: $session_data.capture1
                                status: ($session_data.capture2? | default "")
                                is_current: $is_current
                                display: $"($status_indicator) ($session_data.capture0) │ Created ($session_data.capture1)"
                            }
                        } else {
                            # Fallback parsing for simple format
                            let name = ($clean_line | str replace '\s.*' '')
                            if ($name | str length) > 0 {
                                {
                                    name: $name
                                    created: "unknown"
                                    status: ""
                                    is_current: false
                                    display: $"⚪ ($name)"
                                }
                            } else {
                                null
                            }
                        }
                    }
                } 
                | compact
            )
            
            if ($sessions_info | is-empty) {
                print "❌ No active zellij sessions found"
                print "💡 Use 'zs new <name>' to create a new session"
                return
            }
            
            # Create enhanced display with preview
            let display_list = ($sessions_info | each {|s| $s.display})
            let temp_file = $"/tmp/zellij_sessions_(random chars -l 8).txt"
            $display_list | save $temp_file
            
            # Build fzf command with enhanced options
            let preview_cmd = if $use_preview {
                "--preview 'echo \"Session Details:\"; echo \"Name: {2}\"; echo \"Created: {4} {5} {6}\"; echo \"Status: Current session\" | head -10'"
            } else { "" }
            
            let fzf_opts = [
                $"--height=($SESSION_CONFIG.session_height)"
                "--layout=reverse"
                "--border=rounded"
                "--margin=2%"
                "--padding=1"
                $"--preview-window=right:($SESSION_CONFIG.preview_size):wrap"
                "--prompt='🖥️  Select Zellij Session: '"
                "--header='Enter: Switch │ Ctrl-C: Cancel │ Ctrl-N: New Session' | Ctrl-d: Delete Session under Cursor"
                "--bind='ctrl-n:execute(echo __CREATE_NEW__)'"
                "--bind='ctrl-d:execute(echo __DELETE__)'"
                $preview_cmd
            ] | where {|x| $x != ""} | str join " "
            
            let fzf_cmd = $"cat ($temp_file) | fzf ($fzf_opts)"
            
            # Execute with proper zellij floating pane syntax
            let result = if $use_floating {
                if (multiplexer is-active) {
                    # Create a temporary script for complex fzf execution
                    let script_file = $"/tmp/zellij_session_script_(random chars -l 8).sh"
                    $"#!/bin/bash\n($fzf_cmd)" | save $script_file
                    chmod +x $script_file
                    
                    # FIXED: Use exec-zellij with corrected syntax
                    if $use_large {
                        exec-zellij $"bash ($script_file)" --floating --name "session-switcher"
                    } else {
                        exec-zellij $"bash ($script_file)" --floating --name "session-switcher"
                    }
                    rm -f $script_file $temp_file
                    return
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
            
            # Handle special commands and session switching
            if ($result | str contains "__CREATE_NEW__") {
                print "🆕 Creating new session..."
                let new_name = (input "Enter session name: ")
                if ($new_name | str length) > 0 {
                    zs new $new_name
                }
            } else if ($result | str contains "__DELETE__") {
                let session_name = ($result | str replace '^[🟢⚪]\s+' '' | split column " │ " | get column1.0 | str trim)
                print $"💀 Removing session: ($session_name)"
                ^zellij action kill-session $session_name
      } else if ($result | is-not-empty) {
                let session_name = ($result | str replace '^[🟢⚪]\s+' '' | split column " │ " | get column1.0 | str trim)
                print $"🔄 Switching to session: ($session_name)"
                
                if (multiplexer is-active) {
                    # Use the correct zellij session switch command
                    ^zellij action go-to-tab-name $session_name
                } else {
                    ^zellij attach $session_name
                }
            }
        }
        "tmux" => {
            # Enhanced TMux session management
            let sessions_raw = (^tmux list-sessions -F "#{session_name}:#{session_created}:#{session_attached}" | lines)
            
            if ($sessions_raw | is-empty) {
                print "❌ No tmux sessions available"
                print "💡 Use 'zs new <name>' to create a new session"
                return
            }
            
            let sessions_info = ($sessions_raw | each {|line|
                let parts = ($line | split column ":")
                let attached = if ($parts | get column3) == "1" { "🟢 (attached)" } else { "⚪" }
                {
                    name: ($parts | get column1)
                    created: ($parts | get column2)
                    attached: $attached
                    display: $"($attached) ($parts.column1) │ Created ($parts.column2)"
                }
            })
            
            let display_list = ($sessions_info | each {|s| $s.display})
            let temp_file = $"/tmp/tmux_sessions_(random chars -l 8).txt"
            $display_list | save $temp_file
            
            let preview_cmd = if $use_preview {
                "--preview 'tmux list-windows -t {2} 2>/dev/null || echo \"Session details unavailable\"'"
            } else { "" }
            
            let fzf_opts = [
                $"--height=($SESSION_CONFIG.session_height)"
                "--layout=reverse"
                "--border=rounded"
                "--margin=2%"
                "--padding=1"
                $"--preview-window=right:($SESSION_CONFIG.preview_size):wrap"
                "--prompt='🖥️  Select TMux Session: '"
                "--header='Enter: Switch │ Ctrl-C: Cancel'"
                $preview_cmd
            ] | where {|x| $x != ""} | str join " "
            
            let fzf_cmd = $"cat ($temp_file) | fzf ($fzf_opts)"
            let result = (bash -c $fzf_cmd)
            rm -f $temp_file
            
            if ($result | is-not-empty) {
                let session_name = ($result | str replace '^[🟢⚪]\s+' '' | split column " │ " | get column1.0 | str trim)
                print $"🔄 Switching to session: ($session_name)"
                
                if (multiplexer is-active) {
                    ^tmux switch-client -t $session_name
                } else {
                    ^tmux attach-session -t $session_name
                }
            }
        }
        _ => {
            print "❌ No terminal multiplexer detected"
            print "💡 Consider installing zellij or tmux for session management"
        }
    }
}

# Quick session switcher (optimized for keyboard shortcut)
export def "zs quick" [] {
    zs switch --floating --large --preview
}

# Session management commands
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
    --floating(-f)         # Run in floating pane
] {
    let mux = (multiplexer detect)
    
    match $mux {
        "zellij" => {
            let sessions = (^zellij list-sessions --no-formatting | lines | each {|line|
                let clean = (strip-ansi $line | str trim)
                if not ($clean | str contains "EXITED") and ($clean | str length) > 0 {
                    ($clean | str replace '\s.*' '')
                } else { null }
            } | compact)
            
            if ($sessions | is-empty) {
                print "❌ No sessions to kill"
                return
            }
            
            let temp_file = $"/tmp/zellij_kill_(random chars -l 8).txt"
            $sessions | save $temp_file
            
            let fzf_cmd = $"cat ($temp_file) | fzf --prompt='💀 Kill Session: ' --multi --header='Space: Select │ Enter: Confirm │ Ctrl-C: Cancel'"
            let result = (bash -c $fzf_cmd | lines)
            rm -f $temp_file
            
            if ($result | is-not-empty) {
                for session in $result {
                    print $"💀 Killing session: ($session)"
                    ^zellij kill-session $session
                }
            }
        }
        "tmux" => {
            let sessions = (^tmux list-sessions -F "#{session_name}" | lines)
            
            if ($sessions | is-empty) {
                print "❌ No sessions to kill"
                return
            }
            
            let temp_file = $"/tmp/tmux_kill_(random chars -l 8).txt"
            $sessions | save $temp_file
            
            let fzf_cmd = $"cat ($temp_file) | fzf --prompt='💀 Kill Session: ' --multi --header='Space: Select │ Enter: Confirm │ Ctrl-C: Cancel'"
            let result = (bash -c $fzf_cmd | lines)
            rm -f $temp_file
            
            if ($result | is-not-empty) {
                for session in $result {
                    print $"💀 Killing session: ($session)"
                    ^tmux kill-session -t $session
                }
            }
        }
        _ => {
            print "❌ No terminal multiplexer detected"
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
    
    match $mux {
        "zellij" => {
            let sessions = (^zellij list-sessions --no-formatting | lines | each {|line|
                let clean = (strip-ansi $line | str trim)
                if not ($clean | str contains "EXITED") and ($clean | str length) > 0 {
                    let session_name = ($clean | str replace '\s.*' '')
                    let age = (get-session-age $session_name)
                    
                    if $age >= $days {
                        {
                            name: $session_name
                            age_days: $age
                            should_clean: true
                        }
                    } else {
                        {
                            name: $session_name
                            age_days: $age
                            should_clean: false
                        }
                    }
                } else { null }
            } | compact | where should_clean)
            
            if ($sessions | is-empty) {
                print $"✅ No zellij sessions older than ($days) days found"
                return
            }
            
            print $"🧹 Found ($sessions | length) sessions older than ($days) days:"
            $sessions | select name age_days | table
            
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
                for session in $sessions {
                    print $"🧹 Cleaning session: ($session.name) (($session.age_days) )days old"
                    ^zellij kill-session $session.name
                }
                print $"✅ Cleaned ($sessions | length) sessions"
            } else {
                print "❌ Cleanup cancelled"
            }
        }
        "tmux" => {
            # TMux has better timestamp support
            let sessions_raw = (^tmux list-sessions -F "#{session_name}:#{session_created}" | lines)
            
            let current_time = (date now | format date "%s" | into int)
            let threshold_seconds = ($days * 86400)
            
            let old_sessions = ($sessions_raw | each {|line|
                let parts = ($line | split column ":")
                let session_name = ($parts | get column1)
                let created_timestamp = ($parts | get column2 | into int)
                let age_seconds = ($current_time - $created_timestamp)
                let age_days = ($age_seconds / 86400)
                
                if $age_days >= $days {
                    {
                        name: $session_name
                        age_days: ($age_days | math floor)
                        should_clean: true
                    }
                } else {
                    null
                }
            } | compact)
            
            if ($old_sessions | is-empty) {
                print $"✅ No tmux sessions older than ($days) days found"
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
                input $"Are you sure you want to clean these sessions? (y/N): "
            }
            
            if ($confirm | str downcase) == "y" {
                for session in $old_sessions {
                    print $"🧹 Cleaning session: ($session.name)"
                    ^tmux kill-session -t $session.name
                }
                print $"✅ Cleaned ($old_sessions | length) sessions"
            } else {
                print "❌ Cleanup cancelled"
            }
        }
        _ => {
            print "❌ No terminal multiplexer detected"
        }
    }
}

# Session status overview
export def "zs status" [] {
    let mux = (multiplexer detect)
    
    match $mux {
        "zellij" => {
            print "🖥️  Zellij Session Status"
            print "========================"
            
            let raw_output = (^zellij list-sessions --no-formatting | complete)
            if $raw_output.exit_code == 0 {
                let sessions = ($raw_output.stdout | lines | each {|line|
                    let clean = (strip-ansi $line | str trim)
                    if ($clean | str length) > 0 and not ($clean | str contains "EXITED") {
                        $clean
                    } else { null }
                } | compact)
                
                print $"📊 Total active sessions: ($sessions | length)"
                for session in $sessions {
                    print $"  • ($session)"
                }
            } else {
                print "❌ Failed to get session information"
            }
        }
        "tmux" => {
            print "🖥️  TMux Session Status"
            print "======================"
            
            let sessions = (^tmux list-sessions 2>/dev/null | complete)
            if $sessions.exit_code == 0 {
                let session_lines = ($sessions.stdout | lines)
                print $"📊 Total active sessions: ($session_lines | length)"
                for session in $session_lines {
                    print $"  • ($session)"
                }
            } else {
                print "❌ No tmux sessions or tmux not running"
            }
        }
        _ => {
            print "❌ No terminal multiplexer detected"
            print "💡 Install zellij or tmux for session management"
        }
    }
}

