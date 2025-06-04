# Session Manager Utilities for Nushell (Zellij & TMux)
# Author: walkeratmind
# Created: 2025-05-27
# Updated: 2025-05-29 07:13:35
# Description: Enhanced utilities for unified session management

export const FZF_DEFAULTS = {
    height: "80%"
    width: "120"
    preview_size: "60%"
    border_style: "rounded"
    margin: "2%"
    padding: "1"
}

# Tool detection
export def "tool exists" [name: string] {
    not (which $name | is-empty)
}

# Enhanced multiplexer detection
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

# Check if specific multiplexer is running
export def "multiplexer is-running" [name: string] {
    match $name {
        "zellij" => {
            let result = (^zellij list-sessions --no-formatting 2>/dev/null | complete)
            $result.exit_code == 0
        }
        "tmux" => {
            let result = (^tmux list-sessions 2>/dev/null | complete)
            $result.exit_code == 0
        }
        _ => false
    }
}

# Check if multiplexer has active sessions
export def "multiplexer has-sessions" [name: string] {
    match $name {
        "zellij" => {
            let result = (^zellij list-sessions --no-formatting 2>/dev/null | complete)
            if $result.exit_code == 0 {
                let sessions = ($result.stdout | lines | where {|line| 
                    let clean = (strip-ansi $line | str trim)
                    ($clean | str length) > 0 and not ($clean | str contains "EXITED")
                })
                ($sessions | length) > 0
            } else {
                false
            }
        }
        "tmux" => {
            let result = (^tmux list-sessions 2>/dev/null | complete)
            if $result.exit_code == 0 {
                let sessions = ($result.stdout | lines | where {|line| ($line | str trim | str length) > 0})
                ($sessions | length) > 0
            } else {
                false
            }
        }
        _ => false
    }
}

# check if the session is tmux one
export def "tmux-has-session" [session_name: string] {
    try {
        ^tmux has-session -t $session_name
        true
    } catch {
        false
    }
}
export def "zellij-has-session" [session_name: string] {
# zellij list-sessions | lines | any { |line| $line | str contains "my-session" }
  try {
      let sessions = ^zellij list-sessions | lines | where ($it | str trim) != ""
      $sessions | any { |session| ($session | str trim) == $session_name }
  } catch {
      false
  }
}

# validate session name
export def "validate-session-name" [name: string] {
    let trimmed = ($name | str trim)
    
    if ($trimmed | str length) == 0 {
        return false
    }
    
    # Check for invalid characters (basic validation)
    if ($trimmed | str contains ":") or ($trimmed | str contains " ") {
        return false
    }
    
    true
}


# Strip ANSI codes from text (enhanced)
export def "strip-ansi" [text: string] {
    $text 
    | str replace -a '\x1b\[[0-9;]*[mK]' '' 
    | str replace -a '\x1b\[' ''
    | str replace -a '\x1b\[[0-9;]*H' ''
    | str replace -a '\x1b\[[0-9;]*J' ''
    | str replace -a '\x1b\[[0-9;]*A' ''
    | str replace -a '\x1b\[[0-9;]*B' ''
    | str replace -a '\x1b\[[0-9;]*C' ''
    | str replace -a '\x1b\[[0-9;]*D' ''
}

# Generate random string for temp files
export def "random-string" [length: int = 8] {
    random chars -l $length
}

# Create temporary file path with proper cache directory handling
export def "create-temp-file" [prefix: string = "temp", extension: string = "txt"] {
    let random_suffix = (random-string 8)
    let cache_dir = ($env.XDG_CACHE_HOME? | default "/tmp")
    
    # Ensure cache directory exists
    if not ($cache_dir | path exists) {
        mkdir $cache_dir
    }
    
    $"($cache_dir)/($prefix)_($random_suffix).($extension)"
}

# Enhanced FZF command builder with better error handling
export def "build-fzf-cmd" [
    input_file: string
    --prompt: string = "Select: "
    --header: string = ""
    --preview: string = ""
    --height: string = "80%"
    --multi = false
    --bind: list<string> = []
    --layout: string = "reverse"
    --border: string = "rounded"
    --margin: string = "2%"
    --padding: string = "1"
    --preview-window: string = "right:60%:wrap"
] {
    if not ($input_file | path exists) {
        error make {msg: $"Input file ($input_file) does not exist"}
    }
    
    mut opts = [
        $"--height=($height)"
        $"--layout=($layout)"
        $"--border=($border)"
        $"--margin=($margin)"
        $"--padding=($padding)"
    ]
    
    # Properly escape special characters in prompts and headers
    if ($prompt | is-not-empty) {
        let escaped_prompt = ($prompt | str replace "'" "'\\''" | str replace '"' '\\"')
        $opts = ($opts | append $"--prompt='($escaped_prompt)'")
    }
    
    if ($header | is-not-empty) {
        let escaped_header = ($header | str replace "'" "'\\''" | str replace '"' '\\"')
        $opts = ($opts | append $"--header='($escaped_header)'")
    }
    
    # Enhanced preview handling
    if ($preview | is-not-empty) {
        let escaped_preview = ($preview | str replace "'" "'\\''" | str replace '"' '\\"')
        $opts = ($opts | append $"--preview='($escaped_preview)'")
        $opts = ($opts | append $"--preview-window=($preview_window)")
    }
    
    if $multi {
        $opts = ($opts | append "--multi")
    }
    
    # Enhanced bind command handling
    for binding in $bind {
        let escaped_binding = ($binding | str replace "'" "'\\''" | str replace '"' '\\"')
        $opts = ($opts | append $"--bind='($escaped_binding)'")
    }
    
    let fzf_options = ($opts | str join " ")
    $"cat ($input_file) | fzf ($fzf_options)"
}

# Execute FZF with better error handling
export def "exec-fzf-simple" [fzf_command: string] {
    try {
        let result = (bash -c $fzf_command | complete)
        if $result.exit_code == 0 {
            $result.stdout | str trim
        } else {
            ""
        }
    } catch {
        ""
    }
}

# Execute FZF in floating window based on current multiplexer
export def "exec-fzf-floating" [
    fzf_command: string
    --width: string = "100"
    --height: string = "30"
    --multiplexer: string
] {
    let mux = if ($multiplexer | is-not-empty) {
        $multiplexer
    } else {
        multiplexer detect
    }
    
    # Create a script file for the FZF command
    let script_file = (create-temp-file "fzf_script" "sh")
    $"#!/bin/bash\nset -e\n($fzf_command)" | save $script_file
    chmod +x $script_file
    
    let result = try {
        match $mux {
            "zellij" => {
                ^zellij run --floating --width $width --height $height --close-on-exit -- bash $script_file | str trim
            }
            "tmux" => {
                ^tmux display-popup -w $width -h $height -E "bash $script_file" | str trim
            }
            _ => {
                bash $script_file | str trim
            }
        }
    } catch {
        # Fallback to regular execution
        bash $script_file | str trim
    }
    
    # Cleanup
    cleanup-files [$script_file]
    $result
}

# Safe file cleanup with enhanced error handling
export def "cleanup-files" [files: list<string>] {
    for file in $files {
        try {
            if ($file | path exists) {
                rm -f $file
            }
        } catch {
            # Silently ignore cleanup errors, but could log if needed
        }
    }
}

# Safe save with overwrite and enhanced error handling
export def "safe-save" [data, file_path: string] {
    try {
        # Ensure parent directory exists
        let parent_dir = ($file_path | path dirname)
        if not ($parent_dir | path exists) {
            mkdir $parent_dir
        }
        
        # Force overwrite if file exists
        $data | save --force $file_path
    } catch {
        # If that fails, remove and try again
        try {
            if ($file_path | path exists) {
                rm -f $file_path
            }
            $data | save $file_path
        } catch {
            error make {msg: $"Failed to save to ($file_path)"}
        }
    }
}


# Enhanced temp file management
export def "create-session-temp-file" [prefix: string, data: any] {
    let temp_file = (create-temp-file $prefix "txt")
    safe-save $data $temp_file
    $temp_file
}


# Get session count for a multiplexer
export def "get-session-count" [mux: string] {
    match $mux {
        "zellij" => {
            let result = (^zellij list-sessions --no-formatting 2>/dev/null | complete)
            if $result.exit_code == 0 {
                let sessions = ($result.stdout | lines | where {|line|
                    let clean = (strip-ansi $line | str trim)
                    ($clean | str length) > 0 and not ($clean | str contains "EXITED")
                })
                $sessions | length
            } else {
                0
            }
        }
        "tmux" => {
            let result = (^tmux list-sessions 2>/dev/null | complete)
            if $result.exit_code == 0 {
                let sessions = ($result.stdout | lines | where {|line| ($line | str trim | str length) > 0})
                $sessions | length
            } else {
                0
            }
        }
        _ => 0
    }
}

# Core functionality - DRY principle
export def "detect-multiplexer" [--preferred: string] {
    let current = (multiplexer detect)
    
    if $current != "none" { return $current }
    
    if ($preferred | is-not-empty) and (tool exists $preferred) {
        return $preferred
    }
    
    # Prefer zellij over tmux if both available
    if (tool exists "zellij") { "zellij" } else if (tool exists "tmux") { "tmux" } else { "none" }
}

# Unified session retrieval - single source of truth
export def "get-sessions" [mux: string] {
    match $mux {
        "zellij" => { get-zellij-sessions }
        "tmux" => { get-tmux-sessions }
        _ => { [] }
    }
}

# Zellij session retrieval - fixed shell redirection
export def "get-zellij-sessions" [] {
    let result = (^zellij list-sessions --no-formatting | complete)
    
    if $result.exit_code != 0 { 
        return [] 
    }
    
    if ($result.stdout | str trim | str length) == 0 {
        return []
    }
    
    $result.stdout 
    | lines 
    | each {|line| parse-zellij-session $line}
    | compact
    | where {|session| not ($session.name | str contains "EXITED")}
}

# TMux session retrieval - fixed command
export def "get-tmux-sessions" [] {
    let result = (^tmux list-sessions | complete)
    
    if $result.exit_code != 0 { 
        return [] 
    }
    
    if ($result.stdout | str trim | str length) == 0 {
        return []
    }
    
    # Parse standard tmux output format: "name: N windows (created date)"
    $result.stdout
    | lines
    | where {|line| ($line | str trim | str length) > 0}
    | each {|line| parse-tmux-session-standard $line}
    | compact
}

# Enhanced tmux session retrieval with custom format
export def "get-tmux-sessions-detailed" [] {
    let result = (bash -c "tmux list-sessions -F '#{session_name}:#{session_attached}:#{session_created}:#{session_windows}'" | complete)
    
    if $result.exit_code != 0 { 
        return [] 
    }
    
    if ($result.stdout | str trim | str length) == 0 {
        return []
    }
    
    $result.stdout
    | lines
    | where {|line| ($line | str trim | str length) > 0}
    | each {|line| parse-tmux-session $line}
    | compact
}

# Fixed Zellij session parsing
export def "parse-zellij-session" [line: string] {
    let clean_line = ($line | str trim)
    if ($clean_line | str length) == 0 {
        return null
    }
    
    # Skip EXITED sessions
    if ($clean_line | str contains "EXITED") {
        return null
    }
    
    # Handle various Zellij output formats
    # Try to extract session name first (everything before space or bracket)
    let name_parts = ($clean_line | parse -r '^([^\s\[]+)')
    if ($name_parts | length) == 0 {
        return null
    }
    
    let session_name = ($name_parts | first | get capture0)
    let is_current = ($clean_line | str contains "(current)")
    
    # Try to extract creation time
    let created = if ($clean_line | str contains "[Created") {
        let created_parts = ($clean_line | parse -r '\[Created\s+([^\]]+)\]')
        if ($created_parts | length) > 0 {
            ($created_parts | first | get capture0)
        } else {
            "unknown"
        }
    } else {
        "unknown"
    }
    
    {
        name: $session_name
        created: $created
        is_current: $is_current
        status: (if $is_current { "current" } else { "detached" })
        indicator: (if $is_current { "🟢" } else { "⚪" })
    }
}

# Parse standard TMux session output: "name: N windows (created date) (attached)"
export def "parse-tmux-session-standard" [line: string] {
    let clean_line = ($line | str trim)
    if ($clean_line | str length) == 0 {
        return null
    }
    
    # Standard tmux format: "session_name: 1 windows (created Thu May 29 07:30:00 2025) (attached)"
    let name_match = ($clean_line | parse -r '^([^:]+)')
    if ($name_match | length) == 0 {
        return null
    }
    
    let session_name = ($name_match | first | get capture0 | str trim)
    let is_attached = ($clean_line | str contains "(attached)")
    
    # Extract window count
    let windows = if ($clean_line | str contains " windows") {
        let windows_match = ($clean_line | parse -r '(\d+)\s+windows?')
        if ($windows_match | length) > 0 {
            ($windows_match | first | get capture0)
        } else {
            "1"
        }
    } else {
        "1"
    }
    
    # Extract creation date (rough approximation)
    let created = if ($clean_line | str contains "(created") {
        let created_match = ($clean_line | parse -r '\(created\s+([^)]+)\)')
        if ($created_match | length) > 0 {
            ($created_match | first | get capture0)
        } else {
            "unknown"
        }
    } else {
        "unknown"
    }
    
    {
        name: $session_name
        created: $created
        windows: $windows
        status: (if $is_attached { "attached" } else { "detached" })
        is_current: $is_attached
        indicator: (if $is_attached { "🟢" } else { "⚪" })
    }
}

# Fixed TMux session parsing for custom format - using simple split
export def "parse-tmux-session" [line: string] {
    let clean_line = ($line | str trim)
    if ($clean_line | str length) == 0 {
        return null
    }
    
    # Split by colon - TMux format: name:attached:created:windows
    let parts = ($clean_line | split column ":")
    
    if ($parts | length) < 2 {
        return null
    }
    
    let name = ($parts | get column0)
    let attached_str = ($parts | get column1)
    let created = if ($parts | length) >= 3 { ($parts | get column2) } else { "unknown" }
    let windows = if ($parts | length) >= 4 { ($parts | get column3) } else { "1" }
    
    let attached = ($attached_str == "1")
    
    {
        name: $name
        created: $created
        windows: $windows
        status: (if $attached { "attached" } else { "detached" })
        is_current: $attached
        indicator: (if $attached { "🟢" } else { "⚪" })
    }
}

# Enhanced session age calculation
export def "get-session-age" [session_name: string, mux: string] {
    match $mux {
        "zellij" => { get-zellij-session-age $session_name }
        "tmux" => { get-tmux-session-age $session_name }
        _ => { 0 }
    }
}

# Fixed Zellij session age calculation
export def "get-zellij-session-age" [session_name: string] {
    let result = (^zellij list-sessions --no-formatting | complete)
    if $result.exit_code != 0 { return 0 }
    
    let session_lines = ($result.stdout | lines | where {|line| 
        let clean = ($line | str trim)
        ($clean | str starts-with $session_name)
    })
    
    if ($session_lines | length) == 0 { return 0 }
    
    let clean_line = ($session_lines | first | str trim)
    
    # Look for time patterns in Zellij output
    if ($clean_line | str contains "day") {
        let days_matches = ($clean_line | parse -r '(\d+)\s*days?')
        if ($days_matches | length) > 0 {
            ($days_matches | first | get capture0 | into int)
        } else { 0 }
    } else if ($clean_line | str contains "h") {
        0  # Less than a day
    } else if ($clean_line | str contains "m") {
        0  # Less than an hour
    } else {
        0  # Very recent
    }
}

# Fixed TMux session age calculation
export def "get-tmux-session-age" [session_name: string] {
    let result = (bash -c $"tmux list-sessions -F '#{session_name}:#{session_created}'" | complete)
    if $result.exit_code != 0 { return 0 }
    
    let sessions = ($result.stdout | lines | where {|line| 
        let clean = ($line | str trim)
        ($clean | str starts-with $session_name)
    })
    
    if ($sessions | length) == 0 { return 0 }
    
    try {
        let session_line = ($sessions | first)
        let parts = ($session_line | split column ":")
        if ($parts | length) < 2 { return 0 }
        
        let created_timestamp = ($parts | get column1 | into int)
        let current_timestamp = (date now | format date "%s" | into int)
        let age_seconds = ($current_timestamp - $created_timestamp)
        ($age_seconds / 86400)  # Convert to days
    } catch {
        0
    }
}

# Session operations
# export def "create-session" [name: string, mux: string] {
#     print $"🆕 Creating new ($mux) session: ($name)"
#     match $mux {
#         "zellij" => { ^zellij --session $name }
#         "tmux" => { 
#             ^tmux new-session -d -s $name
#         }
#         _ => { print "❌ Unsupported multiplexer" }
#     }
# }
export def "create-session" [
    name: string, 
    mux: string, 
    --dir (-d): string = "" 
] {
    print $"🆕 Creating new ($mux) session: ($name)"
    
    let session_dir = if ($dir | is-empty) { 
        $env.PWD 
    } else { 
        $dir | path expand
    }
    
    if not ($session_dir | path exists) {
        print $"❌ Directory does not exist: ($session_dir)"
        return
    }
    
    match $mux {
        "zellij" => { 
            cd $session_dir
            ^zellij --session $name 
        }
        "tmux" => { 
            ^tmux new-session -d -s $name -c $session_dir
        }
        _ => { print "❌ Unsupported multiplexer" }
    }
}

export def "switch-session" [name: string, mux: string] {
    print $"🔄 Switching to ($mux) session: ($name)"
    match $mux {
        "zellij" => { switch-zellij-session $name }
        "tmux" => { switch-tmux-session $name }
        _ => { print "❌ Unsupported multiplexer" }
    }
}

export def "switch-zellij-session" [name: string] {
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

export def "switch-tmux-session" [name: string] {
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
        }
    }
}

export def "kill-session" [name: string, mux: string] {
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
export def "format-session-display" [session: record, mux: string] {
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


# Extract session name from FZF result
export def "extract-session-name" [result: string] {
    # First remove the emoji indicator
    let without_emoji = ($result | str replace -r '^[🟢⚪]\s+' '')
    
    # Split by │ and take the first part, then trim
    let parts = ($without_emoji | split column "│")
    ($parts | first | get column1 | str trim)
}


