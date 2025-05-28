# FZF Menu Integration
# Author: walkeratmind  
# Created: 2025-05-27
# Updated: 2025-05-27 14:43:40
# Description: Main menu integrating session management and utilities

# Import both modules (adjust paths as needed)
use zellij-session.nu *
use fzf-utils.nu *

# Enhanced main menu with full functionality
export def "zf menu" [
    --floating(-f)         # Run in floating pane
] {
    let menu_items = [
        "📁 files         - Browse and open files"
        "📂 dirs          - Browse directories"
        "🖥️  session       - Manage multiplexer sessions"
        "🆕 session-new   - Create new session"
        "💀 session-kill  - Kill existing sessions"
        "🧹 session-clean - Clean old sessions (7+ days)"
        "📊 status        - Session status overview"
        "🔄 processes     - Browse running processes"
        "🌿 git-branches  - Git branch switcher"
        "📜 history       - Command history browser"
        "🌍 env           - Environment variables"
        "📦 packages      - Package manager integration"
        "🌐 network       - Network connections"
        "📊 monitor       - System monitoring"
        "🏥 doctor        - Health check"
    ]
    
    let temp_file = $"/tmp/fzf_menu_(random chars -l 8).txt"
    $menu_items | save $temp_file
    
    let fzf_opts = [
        "--height=80%"
        "--layout=reverse"
        "--border=rounded"
        "--margin=2%"
        "--padding=1"
        "--prompt='🎯 FZF Menu: '"
        "--header='Enter: Select │ Ctrl-C: Cancel'"
        "--preview='echo \"Action: {2}\"; echo \"Description: {4..}\"'"
        "--preview-window=right:40%"
    ] | str join " "
    
    let fzf_cmd = $"cat ($temp_file) | fzf ($fzf_opts)"
    let selection = (bash -c $fzf_cmd)
    rm -f $temp_file
    
    if ($selection | is-not-empty) {
        let action = ($selection | split row " " | get 1)
        
        match $action {
            # File operations
            "files" => { zf files --floating=$floating --preview }
            "dirs" => { zf dirs --floating=$floating --preview }
            
            # Session management (from zellij-session-manager.nu)
            "session" => { zs switch --floating=$floating --large }
            "session-new" => { zs new }
            "session-kill" => { zs kill --floating=$floating }
            "session-clean" => { 
                let days = (input "Days threshold (default 7): ")
                let threshold = if ($days | str length) > 0 { ($days | into int) } else { 7 }
                zs clean --days $threshold
            }
            "status" => { zs status }
            
            # Utilities (from fzf-utils.nu)
            "processes" => { zf processes --floating=$floating }
            "git-branches" => { zf git-branches --floating=$floating }
            "history" => { zf history --floating=$floating }
            "env" => { zf env --floating=$floating }
            "packages" => { 
                let search_term = (input "Search packages (optional): ")
                if ($search_term | str length) > 0 {
                    zf packages --search $search_term --floating=$floating
                } else {
                    zf packages --floating=$floating
                }
            }
            "network" => { zf network --floating=$floating }
            "monitor" => { zf monitor --floating=$floating }
            "doctor" => { zf doctor }
            
            _ => { print "❌ Unknown action" }
        }
    }
}

# Quick access aliases for convenience
export alias ss = zs quick           # Quick session switcher  
export alias sn = zs new             # New session
export alias sk = zs kill            # Kill session
export alias sl = zs list            # List sessions
export alias sc = zs clean           # Clean sessions
export alias ff = zf files           # File finder
export alias dd = zf dirs            # Directory finder
export alias pp = zf processes       # Process finder
export alias gg = zf git-branches    # Git branch switcher
export alias hh = zf history         # History browser
export alias mm = zf menu            # Main menu

# Setup helper
export def "zf setup-shortcuts" [] {
    print "⌨️  Setting up keyboard shortcuts..."
    print ""
    print "🔧 Nushell aliases (add to config.nu):"
    print "use path/to/zf-menu.nu *"
    print ""
    print "Quick aliases:"
    print "ss = zs quick      # Quick session switcher"
    print "sn = zs new        # New session"
    print "sk = zs kill       # Kill session"
    print "sl = zs list       # List sessions"
    print "sc = zs clean      # Clean sessions"
    print "ff = zf files      # File finder"
    print "dd = zf dirs       # Directory finder"
    print "pp = zf processes  # Process finder"
    print "gg = zf git-branches # Git branch switcher"
    print "hh = zf history    # History browser"
    print "mm = zf menu       # Main menu"
    print ""
    print "⌨️  Zellij keybindings (add to ~/.config/zellij/config.kdl):"
    print "// Session management in normal mode"
    print "bind \"Ctrl s\" { Run \"nu\" \"-c\" \"ss\"; }"
    print "bind \"Ctrl f\" { Run \"nu\" \"-c\" \"ff\"; }"
    print "bind \"Ctrl m\" { Run \"nu\" \"-c\" \"mm\"; }"
    print ""
    print "🧹 Session cleanup examples:"
    print "zs clean                    # Clean sessions older than 7 days"
    print "zs clean --days 14          # Clean sessions older than 14 days"
    print "zs clean --dry-run          # See what would be cleaned"
    print "zs clean --force            # Clean without confirmation"
}
