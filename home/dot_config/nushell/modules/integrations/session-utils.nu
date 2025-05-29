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
