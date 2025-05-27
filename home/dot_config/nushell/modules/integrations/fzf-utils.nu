# FZF Utilities for Nushell
# Author: walkeratmind
# Created: 2025-05-27
# Updated: 2025-05-27 14:51:24
# Description: General FZF utilities and file operations - CORRECTED

# Module metadata
export const FZF_UTILS_INFO = {
    name: "fzf-utils"
    version: "2.4.2"
    author: "walkeratmind"
    created: "2025-05-27"
    updated: "2025-05-27 14:51:24"
    description: "FZF utilities for file operations and general purpose - CORRECTED"
    dependencies: ["fzf"]
    optional_deps: ["bat", "eza", "fd", "ripgrep", "zoxide", "delta", "jq"]
}

# Configuration constants
export const FZF_CONFIG = {
    preview_size: "60%"
    border_style: "rounded"
    floating_margin: "5%"
    default_height: "70%"
}

# Tool detection
export def "tool exists" [name: string] {
    not (which $name | is-empty)
}

# Multiplexer detection (needed for some operations)
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

# Intelligent command execution - only use multiplexer when beneficial
export def "exec smart" [
    command: string
    --floating(-f)          # Run in floating pane
    --in-place(-i)         # Run in-place
    --keep(-k)             # Keep pane open
    --name(-n): string     # Custom name
    --force-multiplexer    # Force multiplexer usage
] {
    let mux = (multiplexer detect)
    let should_use_mux = $force_multiplexer or $floating or $keep or ($name | is-not-empty)
    
    if $should_use_mux and $mux != "none" {
        match $mux {
            "zellij" => { 
                mut args = ["run"]
                if ($name | is-not-empty) { 
                    $args = ($args | append "--name")
                    $args = ($args | append $name)
                }
                if $floating { 
                    $args = ($args | append "--floating")
                    $args = ($args | append "--width")
                    $args = ($args | append "100")
                    $args = ($args | append "--height")
                    $args = ($args | append "30")
                }
                if $in_place { $args = ($args | append "--in-place") }
                if not $keep { $args = ($args | append "--close-on-exit") }
                
                $args = ($args | append "--")
                $args = ($args | append "bash")
                $args = ($args | append "-c")
                $args = ($args | append $command)
                
                ^zellij ...$args
            }
            "tmux" => { 
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
            _ => { bash -c $command }
        }
    } else {
        bash -c $command
    }
}

# Enhanced file browser with FZF
export def "zf files" [
    --edit(-e)             # Open selected file in editor
    --floating(-f)         # Run in floating pane
    --preview(-p)          # Enable preview (default: true)
    --hidden(-h)           # Include hidden files
    --directory(-d): string # Start in specific directory
] {
    let preview = $preview != false  # Default to true unless explicitly false
    let start_dir = if ($directory | is-not-empty) { $directory } else { "." }
    
    # Change to directory if specified
    if ($directory | is-not-empty) {
        if not ($directory | path exists) {
            print $"❌ Directory ($directory) does not exist"
            return
        }
        cd $directory
    }
    
    let find_cmd = if (tool exists "fd") {
        let hidden_flag = if $hidden { "--hidden" } else { "" }
        $"fd --type f ($hidden_flag) --follow --exclude .git . ($start_dir)"
    } else {
        let hidden_flag = if $hidden { "" } else { "-not -path '*/.*'" }
        $"find ($start_dir) -type f ($hidden_flag) ! -path '*/.git/*'"
    }
    
    let preview_cmd = if $preview {
        if (tool exists "bat") {
            "--preview 'bat --color=always --style=numbers --line-range=:500 {}' --preview-window=right:60%"
        } else {
            "--preview 'head -n 50 {}' --preview-window=right:50%"
        }
    } else { "" }
    
    let fzf_opts = [
        $"--height=($FZF_CONFIG.default_height)"
        "--layout=reverse"
        "--border=rounded"
        "--margin=2%"
        "--padding=1"
        "--prompt='📁 Files: '"
        "--header='Enter: Select │ Ctrl-E: Edit │ Ctrl-C: Cancel'"
        "--bind='ctrl-e:execute($env.EDITOR? | default \"nano\") {}'"
        $preview_cmd
    ] | where {|x| $x != ""} | str join " "
    
    let fzf_cmd = $"($find_cmd) | fzf ($fzf_opts)"
    
    if $edit {
        let editor = $env.EDITOR? | default "nano"
        let full_cmd = $"file=$(($fzf_cmd)); if [ -n \"$file\" ]; then ($editor) \"$file\"; fi"
        exec smart $full_cmd --floating=$floating --name="file-editor"
    } else {
        let result = (bash -c $fzf_cmd)
        if ($result | is-not-empty) {
            $result
        }
    }
}

# Directory browser with FZF
export def "zf dirs" [
    --cd(-c)               # Change to selected directory
    --floating(-f)         # Run in floating pane
    --preview(-p)          # Enable preview (default: true)
    --hidden(-h)           # Include hidden directories
] {
    let preview = $preview != false
    
    let find_cmd = if (tool exists "fd") {
        let hidden_flag = if $hidden { "--hidden" } else { "" }
        $"fd --type d ($hidden_flag) --follow --exclude .git"
    } else {
        let hidden_flag = if $hidden { "" } else { "-not -path '*/.*'" }
        $"find . -type d ($hidden_flag) ! -path '*/.git/*'"
    }
    
    let preview_cmd = if $preview {
        if (tool exists "eza") {
            "--preview 'eza -la --color=always {}' --preview-window=right:50%"
        } else {
            "--preview 'ls -la {}' --preview-window=right:50%"
        }
    } else { "" }
    
    let fzf_opts = [
        $"--height=($FZF_CONFIG.default_height)"
        "--layout=reverse"
        "--border=rounded"
        "--margin=2%"
        "--padding=1"
        "--prompt='📂 Directories: '"
        "--header='Enter: Select │ Ctrl-C: Cancel'"
        $preview_cmd
    ] | where {|x| $x != ""} | str join " "
    
    let fzf_cmd = $"($find_cmd) | fzf ($fzf_opts)"
    let result = (bash -c $fzf_cmd)
    
    if ($result | is-not-empty) {
        if $cd {
            cd $result
            print $"📂 Changed to: ($result)"
        } else {
            $result
        }
    }
}

# Process browser with FZF - FIXED
export def "zf processes" [
    --kill(-k)             # Kill selected process
    --floating(-f)         # Run in floating pane
] {
    let ps_cmd = if (tool exists "procs") {
        "procs --color=always"
    } else {
        "ps aux"
    }
    
    let fzf_opts = [
        $"--height=($FZF_CONFIG.default_height)"
        "--layout=reverse"
        "--border=rounded"
        "--margin=2%"
        "--padding=1"
        "--prompt='🔄 Processes: '"
        "--header='Enter: Select │ Space: Kill │ Ctrl-C: Cancel'"
        "--header-lines=1"
        "--preview='echo \"Process Details:\"; echo \"PID: {2}\"; echo \"Command: {11..}\"'"
        "--preview-window=right:30%"
    ] | str join " "
    
    let fzf_cmd = $"($ps_cmd) | fzf ($fzf_opts)"
    
    if $kill {
        let result = (bash -c $fzf_cmd)
        if ($result | is-not-empty) {
            # FIXED: Added separator " " and filter empty strings, then get PID
            let parts = ($result | split row " " | where {|x| ($x | str length) > 0})
            if ($parts | length) > 1 {
                let pid = ($parts | get 1)
                let confirm = (input $"Kill process ($pid)? (y/N): ")
                if ($confirm | str downcase) == "y" {
                    ^kill $pid
                    print $"💀 Killed process ($pid)"
                }
            } else {
                print "❌ Could not extract PID from process line"
            }
        }
    } else {
        bash -c $fzf_cmd
    }
}

# Git branch switcher with FZF - FIXED
export def "zf git-branches" [
    --remote(-r)           # Include remote branches
    --checkout(-c)         # Checkout selected branch
    --floating(-f)         # Run in floating pane
] {
    if not (git rev-parse --git-dir | complete | get exit_code) == 0 {
        print "❌ Not in a git repository"
        return
    }
    
    let branch_cmd = if $remote {
        "git branch -a --color=always"
    } else {
        "git branch --color=always"
    }
    
    let fzf_opts = [
        $"--height=($FZF_CONFIG.default_height)"
        "--layout=reverse"
        "--border=rounded"
        "--margin=2%"
        "--padding=1"
        "--prompt='🌿 Git Branches: '"
        "--header='Enter: Select │ Ctrl-C: Cancel'"
        "--preview='git show --color=always {1} | head -50'"
        "--preview-window=right:60%"
    ] | str join " "
    
    let fzf_cmd = $"($branch_cmd) | fzf ($fzf_opts)"
    let result = (bash -c $fzf_cmd)
    
    if ($result | is-not-empty) {
        # FIXED: Better branch name extraction
        let branch = ($result | str replace '^\*?\s*' '' | str replace '^remotes/origin/' '' | str trim)
        if $checkout {
            ^git checkout $branch
            print $"🌿 Switched to branch: ($branch)"
        } else {
            $branch
        }
    }
}

# Command history browser with FZF
export def "zf history" [
    --execute(-e)          # Execute selected command
    --floating(-f)         # Run in floating pane
] {
    let fzf_opts = [
        $"--height=($FZF_CONFIG.default_height)"
        "--layout=reverse"
        "--border=rounded"
        "--margin=2%"
        "--padding=1"
        "--prompt='📜 History: '"
        "--header='Enter: Select │ Ctrl-E: Execute │ Ctrl-C: Cancel'"
        "--bind='ctrl-e:execute({})+abort'"
        "--tac"  # Reverse chronological order
    ] | str join " "
    
    # Get Nushell history
    let history_file = $nu.history-path
    let fzf_cmd = if ($history_file | path exists) {
        $"cat ($history_file) | fzf ($fzf_opts)"
    } else {
        # Fallback to bash history if available
        $"history | cut -c 8- | fzf ($fzf_opts)"
    }
    
    let result = (bash -c $fzf_cmd)
    
    if ($result | is-not-empty) {
        if $execute {
            print $"🚀 Executing: ($result)"
            bash -c $result
        } else {
            $result
        }
    }
}

# Environment variables browser - FIXED
export def "zf env" [
    --edit(-e)             # Edit selected environment variable
    --floating(-f)         # Run in floating pane
] {
    let env_list = ($env | transpose key value | each {|item|
        $"($item.key)=($item.value)"
    })
    
    let temp_file = $"/tmp/env_vars_(random chars -l 8).txt"
    $env_list | save $temp_file
    
    let fzf_opts = [
        $"--height=($FZF_CONFIG.default_height)"
        "--layout=reverse"
        "--border=rounded"
        "--margin=2%"
        "--padding=1"
        "--prompt='🌍 Environment: '"
        "--header='Enter: Select │ Ctrl-C: Cancel'"
        "--delimiter='='"
        "--preview='echo \"Variable: {1}\"; echo \"Value: {2..}\"'"
        "--preview-window=right:40%"
    ] | str join " "
    
    let fzf_cmd = $"cat ($temp_file) | fzf ($fzf_opts)"
    let result = (bash -c $fzf_cmd)
    rm -f $temp_file
    
    if ($result | is-not-empty) {
        if $edit {
            # FIXED: Use split column with "=" separator
            let parts = ($result | split column "=" name value)
            if ($parts | length) > 0 {
                let var_name = ($parts | get name.0)
                let new_value = (input $"New value for ($var_name): ")
                if ($new_value | str length) > 0 {
                    # Note: This would set in current scope only
                    print $"Setting ($var_name) = ($new_value)"
                    print "Note: Changes only apply to current session"
                }
            }
        } else {
            $result
        }
    }
}

# Package manager integration (if available) - FIXED
export def "zf packages" [
    --install(-i)          # Install selected package
    --search(-s): string   # Search for packages
    --floating(-f)         # Run in floating pane
] {
    # Detect package manager
    let pkg_manager = if (tool exists "brew") {
        "brew"
    } else if (tool exists "apt") {
        "apt"
    } else if (tool exists "yum") {
        "yum"
    } else if (tool exists "pacman") {
        "pacman"
    } else {
        null
    }
    
    if ($pkg_manager | is-empty) {
        print "❌ No supported package manager found"
        return
    }
    
    let search_term = if ($search | is-not-empty) { $search } else { "" }
    
    let search_cmd = match $pkg_manager {
        "brew" => { $"brew search ($search_term)" }
        "apt" => { $"apt search ($search_term)" }
        "yum" => { $"yum search ($search_term)" }
        "pacman" => { $"pacman -Ss ($search_term)" }
        _ => { "" }
    }
    
    if ($search_cmd | str length) == 0 {
        print $"❌ Package search not implemented for ($pkg_manager)"
        return
    }
    
    let fzf_opts = [
        $"--height=($FZF_CONFIG.default_height)"
        "--layout=reverse"
        "--border=rounded"
        "--margin=2%"
        "--padding=1"
        "--prompt='📦 Packages: '"
        "--header='Enter: Select │ Ctrl-I: Install │ Ctrl-C: Cancel'"
        "--bind='ctrl-i:execute(echo Installing {}; sudo ($pkg_manager) install {1})+abort'"
    ] | str join " "
    
    let fzf_cmd = $"($search_cmd) | fzf ($fzf_opts)"
    
    if $install {
        let result = (bash -c $fzf_cmd)
        if ($result | is-not-empty) {
            # FIXED: Better package name extraction
            let parts = ($result | split row " " | where {|x| ($x | str length) > 0})
            if ($parts | length) > 0 {
                let package = ($parts | get 0)
                print $"📦 Installing ($package) with ($pkg_manager)..."
                # This would require sudo permissions
                print $"Run: sudo ($pkg_manager) install ($package)"
            }
        }
    } else {
        bash -c $fzf_cmd
    }
}

# Network connections browser
export def "zf network" [
    --floating(-f)         # Run in floating pane
] {
    let netstat_cmd = if (tool exists "ss") {
        "ss -tulpn"
    } else {
        "netstat -tulpn"
    }
    
    let fzf_opts = [
        $"--height=($FZF_CONFIG.default_height)"
        "--layout=reverse"
        "--border=rounded"
        "--margin=2%"
        "--padding=1"
        "--prompt='🌐 Network: '"
        "--header='Enter: Select │ Ctrl-C: Cancel'"
        "--header-lines=1"
    ] | str join " "
    
    let fzf_cmd = $"($netstat_cmd) | fzf ($fzf_opts)"
    bash -c $fzf_cmd
}

# System monitoring with FZF - FIXED
export def "zf monitor" [
    --floating(-f)         # Run in floating pane
] {
    let monitor_options = [
        "🔄 processes  - View running processes"
        "🌐 network    - View network connections"
        "💾 disk       - View disk usage"
        "🧠 memory     - View memory usage"
        "🌡️  temperature - View system temperature (if available)"
        "📊 resources  - Overall system resources"
    ]
    
    let temp_file = $"/tmp/monitor_menu_(random chars -l 8).txt"
    $monitor_options | save $temp_file
    
    let fzf_opts = [
        $"--height=($FZF_CONFIG.default_height)"
        "--layout=reverse"
        "--border=rounded"
        "--margin=2%"
        "--padding=1"
        "--prompt='📊 Monitor: '"
        "--header='Enter: Select │ Ctrl-C: Cancel'"
        "--preview='echo {2..}'"
        "--preview-window=right:30%"
    ] | str join " "
    
    let fzf_cmd = $"cat ($temp_file) | fzf ($fzf_opts)"
    let selection = (bash -c $fzf_cmd)
    rm -f $temp_file
    
    if ($selection | is-not-empty) {
        # FIXED: Better action extraction
        let parts = ($selection | split row " " | where {|x| ($x | str length) > 0})
        if ($parts | length) > 1 {
            let action = ($parts | get 1)
            
            match $action {
                "processes" => { zf processes --floating=$floating }
                "network" => { zf network --floating=$floating }
                "disk" => { 
                    if (tool exists "duf") {
                        ^duf
                    } else {
                        ^df -h
                    }
                }
                "memory" => { 
                    if (tool exists "free") {
                        ^free -h
                    } else {
                        ^vm_stat  # macOS
                    }
                }
                "temperature" => {
                    if (tool exists "sensors") {
                        ^sensors
                    } else {
                        print "❌ Temperature monitoring not available"
                    }
                }
                "resources" => {
                    if (tool exists "htop") {
                        ^htop
                    } else if (tool exists "top") {
                        ^top
                    } else {
                        print "❌ System monitor not available"
                    }
                }
                _ => { print "❌ Unknown monitor option" }
            }
        }
    }
}

# FZF utilities health check
export def "zf doctor" [] {
    print "🏥 FZF Utilities Health Check"
    print "============================="
    
    print $"🔧 FZF available: (tool exists 'fzf')"
    print $"📟 Multiplexer: (multiplexer detect)"
    
    let optional_tools = ["bat", "eza", "fd", "ripgrep", "zoxide", "delta", "jq", "procs", "duf"]
    for tool in $optional_tools {
        let status = if (tool exists $tool) { "✅" } else { "❌" }
        print $"($status) ($tool)"
    }
    
    print "\n📋 Recommendations:"
    if not (tool exists "fd") { print "  • Install 'fd' for faster file finding" }
    if not (tool exists "bat") { print "  • Install 'bat' for better file previews" }
    if not (tool exists "eza") { print "  • Install 'eza' for enhanced directory listings" }
    if not (tool exists "zoxide") { print "  • Install 'zoxide' for smart directory jumping" }
    if not (tool exists "procs") { print "  • Install 'procs' for better process viewing" }
    if not (tool exists "duf") { print "  • Install 'duf' for better disk usage display" }
}
