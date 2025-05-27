# FZF Session Manager for Nushell
# Author: walkeratmind
# Description: Unified session management (switch, delete, clean) via FZF

# Multiplexer detection
def "multiplexer detect" [] {
    if ($env.ZELLIJ? != null) { "zellij" }
    else if ($env.TMUX? != null) { "tmux" }
    else { "none" }
}

def "multiplexer is-active" [] {
    (multiplexer detect) != "none"
}

def "tool exists" [name: string] {
    not (which $name | is-empty)
}

def "strip-ansi" [text: string] {
    $text | str replace -a '\x1b\[[0-9;]*[mK]' '' | str replace -a '\x1b\[' ''
}

def "get-session-age" [session_name: string] {
    let mux = (multiplexer detect)
    match $mux {
        "zellij" => {
            let raw_output = (^zellij list-sessions --no-formatting | complete)
            if $raw_output.exit_code == 0 {
                let session_lines = ($raw_output.stdout | lines | where {|line|
                    let clean = (strip-ansi $line)
                    ($clean | str starts-with $session_name)
                })
                if ($session_lines | length) > 0 {
                    let session_line = ($session_lines | first)
                    let clean_line = (strip-ansi $session_line)
                    if ($clean_line | str contains "day") {
                        let days_match = ($clean_line | parse -r '(\d+)day')
                        if ($days_match | length) > 0 {
                            ($days_match | first | get capture0 | into int)
                        } else { 0 }
                    } else if ($clean_line | str contains "h") { 0 }
                    else { 0 }
                } else { 0 }
            } else { 0 }
        }
        "tmux" => {
            let session_info = (^tmux list-sessions -F "#{session_name}:#{session_created}" | lines | where {|line|
                ($line | str starts-with $session_name)
            })
            if ($session_info | length) > 0 {
                let created_timestamp = ($session_info | first | split column ":" | get column2 | into int)
                let current_timestamp = (date now | format date "%s" | into int)
                let age_seconds = ($current_timestamp - $created_timestamp)
                ($age_seconds / 86400)
            } else { 0 }
        }
        _ => { 0 }
    }
}

# Main session menu: switch, delete, clean, new
export def "zf session" [
    --floating(-f)
    --large(-l)
    --preview(-p)
    --create(-c): string
] {
    let use_floating = $floating != false
    let use_preview = $preview != false
    let use_large = $large or $use_floating

    # Handle session creation
    if ($create | is-not-empty) {
        let mux = (multiplexer detect)
        match $mux {
            "zellij" => { print $"🆕 Creating new zellij session: ($create)"; ^zellij --session $create; return }
            "tmux" => { print $"🆕 Creating new tmux session: ($create)"; ^tmux new-session -d -s $create; ^tmux attach-session -t $create; return }
            _ => { print "❌ No terminal multiplexer detected"; return }
        }
    }

    let mux = (multiplexer detect)
    match $mux {
        "zellij" => {
            let raw_output = (^zellij list-sessions --no-formatting | complete)
            if $raw_output.exit_code != 0 {
                print "❌ Failed to get zellij sessions"
                return
            }
            let sessions_info = ($raw_output.stdout | lines | each { |line|
                let clean_line = (strip-ansi $line | str trim)
                if ($clean_line | str length) == 0 or ($clean_line | str contains "EXITED") { null }
                else {
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
                        let name = ($clean_line | str replace '\s.*' '')
                        if ($name | str length) > 0 {
                            {
                                name: $name
                                created: "unknown"
                                status: ""
                                is_current: false
                                display: $"⚪ ($name)"
                            }
                        } else { null }
                    }
                }
            } | compact)

            if ($sessions_info | is-empty) {
                print "❌ No active zellij sessions found"
                print "💡 Use 'zf session --create <name>' to create a new session"
                return
            }

            let menu_items = ($sessions_info | each {|s| $"Switch: ($s.display)"} )
            let menu_items = ($menu_items | append "🆕 New session" | append "💀 Delete session(s)" | append "🧹 Clean old sessions")
            let temp_file = $"/tmp/zf_session_menu_(random chars -l 8).txt"
            $menu_items | save $temp_file

            let preview_cmd = if $use_preview {
                "--preview 'echo \"Session: {2}\"'"
            } else { "" }

            let fzf_opts = [
                "--height=80%"
                "--layout=reverse"
                "--border=rounded"
                "--margin=2%"
                "--padding=1"
                "--prompt='🖥️  Session: '"
                "--header='Enter: Select │ Ctrl-C: Cancel'"
                $preview_cmd
            ] | where {|x| $x != ""} | str join " "

            let fzf_cmd = $"cat ($temp_file) | fzf ($fzf_opts)"
            let result = (bash -c $fzf_cmd)
            rm -f $temp_file

            if ($result | is-empty) { return }
            if ($result | str contains "🆕") {
                let new_name = (input "Enter session name: ")
                if ($new_name | str length) > 0 { zf session --create $new_name }
                return
            }
            if ($result | str contains "💀") {
                zf session-kill --floating=$floating
                return
            }
            if ($result | str contains "🧹") {
                let days = (input "Days threshold (default 7): ")
                let threshold = if ($days | str length) > 0 { ($days | into int) } else { 7 }
                zf session-clean --days $threshold
                return
            }
            # Otherwise, switch to selected session
            let session_name = ($result | str replace '^Switch: [🟢⚪]\s+' '' | split column " │ " | get column1.0 | str trim)
            print $"🔄 Switching to session: ($session_name)"
            if (multiplexer is-active) { ^zellij action go-to-tab-name $session_name }
            else { ^zellij attach $session_name }
        }
        "tmux" => {
            let sessions_raw = (^tmux list-sessions -F "#{session_name}:#{session_created}:#{session_attached}" | lines)
            if ($sessions_raw | is-empty) {
                print "❌ No tmux sessions available"
                print "💡 Use 'zf session --create <name>' to create a new session"
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
            let menu_items = ($sessions_info | each {|s| $"Switch: ($s.display)"} )
            let menu_items = ($menu_items | append "🆕 New session" | append "💀 Delete session(s)" | append "🧹 Clean old sessions")
            let temp_file = $"/tmp/zf_session_menu_(random chars -l 8).txt"
            $menu_items | save $temp_file

            let preview_cmd = if $use_preview {
                "--preview 'echo \"Session: {2}\"'"
            } else { "" }

            let fzf_opts = [
                "--height=80%"
                "--layout=reverse"
                "--border=rounded"
                "--margin=2%"
                "--padding=1"
                "--prompt='🖥️  Session: '"
                "--header='Enter: Select │ Ctrl-C: Cancel'"
                $preview_cmd
            ] | where {|x| $x != ""} | str join " "

            let fzf_cmd = $"cat ($temp_file) | fzf ($fzf_opts)"
            let result = (bash -c $fzf_cmd)
            rm -f $temp_file

            if ($result | is-empty) { return }
            if ($result | str contains "🆕") {
                let new_name = (input "Enter session name: ")
                if ($new_name | str length) > 0 { zf session --create $new_name }
                return
            }
            if ($result | str contains "💀") {
                zf session-kill --floating=$floating
                return
            }
            if ($result | str contains "🧹") {
                let days = (input "Days threshold (default 7): ")
                let threshold = if ($days | str length) > 0 { ($days | into int) } else { 7 }
                zf session-clean --days $threshold
                return
            }
            let session_name = ($result | str replace '^Switch: [🟢⚪]\s+' '' | split column " │ " | get column1.0 | str trim)
            print $"🔄 Switching to session: ($session_name)"
            if (multiplexer is-active) { ^tmux switch-client -t $session_name }
            else { ^tmux attach-session -t $session_name }
        }
        _ => {
            print "❌ No terminal multiplexer detected"
            print "💡 Consider installing zellij or tmux for session management"
        }
    }
}

# Delete session(s)
export def "zf session-kill" [
    --floating(-f)
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
            if ($sessions | is-empty) { print "❌ No sessions to kill"; return }
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
            if ($sessions | is-empty) { print "❌ No sessions to kill"; return }
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
        _ => { print "❌ No terminal multiplexer detected" }
    }
}

# Clean old sessions
export def "zf session-clean" [
    --days(-d): int = 7
    --dry-run(-n)
    --force(-f)
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
                        { name: $session_name, age_days: $age, should_clean: true }
                    } else { null }
                } else { null }
            } | compact | where should_clean)
            if ($sessions | is-empty) {
                print $"✅ No zellij sessions older than ($days) days found"
                return
            }
            print $"🧹 Found ($sessions | length) sessions older than ($days) days:"
            $sessions | select name age_days | table
            if $dry_run { print "🔍 Dry run - no sessions were actually cleaned"; return }
            let confirm = if $force { "y" } else { input $"Are you sure you want to clean these sessions? (y/N): " }
            if ($confirm | str downcase) == "y" {
                for session in $sessions {
                    print $"🧹 Cleaning session: ($session.name) (($session.age_days) days old)"
                    ^zellij kill-session $session.name
                }
                print $"✅ Cleaned ($sessions | length) sessions"
            } else { print "❌ Cleanup cancelled" }
        }
        "tmux" => {
            let sessions_raw = (^tmux list-sessions -F "#{session_name}:#{session_created}" | lines)
            let current_time = (date now | format date "%s" | into int)
            let old_sessions = ($sessions_raw | each {|line|
                let parts = ($line | split column ":")
                let session_name = ($parts | get column1)
                let created_timestamp = ($parts | get column2 | into int)
                let age_seconds = ($current_time - $created_timestamp)
                let age_days = ($age_seconds / 86400)
                if $age_days >= $days {
                    { name: $session_name, age_days: ($age_days | math floor), should_clean: true }
                } else { null }
            } | compact)
            if ($old_sessions | is-empty) {
                print $"✅ No tmux sessions older than ($days) days found"
                return
            }
            print $"🧹 Found ($old_sessions | length) sessions older than ($days) days:"
            $old_sessions | select name age_days | table
            if $dry_run { print "🔍 Dry run - no sessions were actually cleaned"; return }
            let confirm = if $force { "y" } else { input $"Are you sure you want to clean these sessions? (y/N): " }
            if ($confirm | str downcase) == "y" {
                for session in $old_sessions {
                    print $"🧹 Cleaning session: ($session.name)"
                    ^tmux kill-session -t $session.name
                }
                print $"✅ Cleaned ($old_sessions | length) sessions"
            } else { print "❌ Cleanup cancelled" }
        }
        _ => { print "❌ No terminal multiplexer detected" }
    }
}
