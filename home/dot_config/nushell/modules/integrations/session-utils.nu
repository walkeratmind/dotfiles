# Author: walkeratmind
# Created: 2025-05-27
# Updated: 2025-05-27 18:07:12
# Description: Reusable utilities for FZF integration in Nushell 

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

# Strip ANSI codes from text
export def "strip-ansi" [text: string] {
    $text | str replace -a '\x1b\[[0-9;]*[mK]' '' | str replace -a '\x1b\[' ''
}

# Generate random string for temp files
export def "random-string" [length: int = 8] {
    random chars -l $length
}

# Create temporary file path (don't create the actual file)
export def "create-temp-file" [prefix: string = "temp", extension: string = "txt"] {
    let random_suffix = (random-string 8)
    $"/tmp/($prefix)_($random_suffix).($extension)"
}

# FIXED: Enhanced FZF command builder with proper shell escaping
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
    # Ensure input file exists
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
    
    # FIXED: Properly escape prompt with quotes
    if ($prompt | is-not-empty) {
        let escaped_prompt = ($prompt | str replace "'" "\\'")
        $opts = ($opts | append $"--prompt='($escaped_prompt)'")
    }
    
    # FIXED: Properly escape header with quotes
    if ($header | is-not-empty) {
        let escaped_header = ($header | str replace "'" "\\'")
        $opts = ($opts | append $"--header='($escaped_header)'")
    }
    
    # FIXED: Properly escape preview command
    if ($preview | is-not-empty) {
        let escaped_preview = ($preview | str replace "'" "\\'")
        $opts = ($opts | append $"--preview='($escaped_preview)'")
        $opts = ($opts | append $"--preview-window=($preview_window)")
    }
    
    if $multi {
        $opts = ($opts | append "--multi")
    }
    
    # FIXED: Properly escape bind commands
    for binding in $bind {
        let escaped_binding = ($binding | str replace "'" "\\'")
        $opts = ($opts | append $"--bind='($escaped_binding)'")
    }
    
    let fzf_options = ($opts | str join " ")
    $"cat ($input_file) | fzf ($fzf_options)"
}

# Execute FZF directly (simplified approach)
export def "exec-fzf-simple" [
    fzf_command: string
] {
    try {
        bash -c $fzf_command
    } catch {
        ""
    }
}

# Safe file cleanup
export def "cleanup-files" [files: list<string>] {
    for file in $files {
        try {
            if ($file | path exists) {
                rm -f $file
            }
        } catch {
            # Ignore cleanup errors
        }
    }
}

# Safe save with overwrite
export def "safe-save" [data, file_path: string] {
    try {
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

# Parse session line with flexible format support
export def "parse-session-line" [line: string, format: string = "auto"] {
    let clean_line = (strip-ansi $line | str trim)
    
    if ($clean_line | str length) == 0 {
        return null
    }
    
    match $format {
        "zellij" => {
            # Try to parse zellij format: "session_name [Created timestamp] (status)"
            let parts = ($clean_line | parse -r '^([^\s\[]+)\s*(?:\[Created\s+([^\]]+)\])?\s*(.*)?$')
            if ($parts | length) > 0 {
                let session_data = ($parts | first)
                let is_current = ($session_data.capture2? | default "" | str contains "current")
                {
                    name: $session_data.capture0
                    created: ($session_data.capture1? | default "unknown")
                    status: ($session_data.capture2? | default "")
                    is_current: $is_current
                    indicator: (if $is_current { "🟢" } else { "⚪" })
                }
            } else {
                let name = ($clean_line | str replace '\s.*' '')
                {
                    name: $name
                    created: "unknown"
                    status: ""
                    is_current: false
                    indicator: "⚪"
                }
            }
        }
        "tmux" => {
            # Parse tmux format: "session_name:created:attached"
            let parts = ($clean_line | split column ":")
            if ($parts | length) >= 3 {
                let attached = ($parts | get column2) == "1"
                {
                    name: ($parts | get column0)
                    created: ($parts | get column1)
                    status: (if $attached { "attached" } else { "detached" })
                    is_current: $attached
                    indicator: (if $attached { "🟢" } else { "⚪" })
                }
            } else {
                null
            }
        }
        _ => {
            # Auto-detect format
            if ($clean_line | str contains "[Created") {
                parse-session-line $line "zellij"
            } else if ($clean_line | str contains ":") {
                parse-session-line $line "tmux"
            } else {
                {
                    name: $clean_line
                    created: "unknown"
                    status: ""
                    is_current: false
                    indicator: "⚪"
                }
            }
        }
    }
}

# Format session display string
export def "format-session-display" [session: record] {
    if ($session.created != "unknown") {
        $"($session.indicator) ($session.name) │ Created ($session.created)"
    } else {
        $"($session.indicator) ($session.name)"
    }
}
