

def update_zellij_tab [] {
    if $env.ZELLIJ != "" {
        let current_dir = (pwd)
        
        # Check if we're in a git repo using a more reliable method
        let git_info = (do { 
            git rev-parse --show-toplevel --show-prefix 2>/dev/null 
        } | complete)
        
        let tab_name = if $git_info.exit_code == 0 {
            let lines = ($git_info.stdout | lines)
            let repo_root = ($lines | get 0 | str trim)
            let git_prefix = ($lines | get 1? | default "" | str trim)
            let repo_name = ($repo_root | path basename)
            
            if ($git_prefix | is-empty) {
                $repo_name
            } else {
                $"($repo_name)/($git_prefix)" | str trim -c '/'
            }
        } else {
            # Fallback to current directory name
            ($current_dir | path basename)
        }
        
        do { zellij action rename-tab $tab_name } | ignore
    }
}

# Set up environment change hook
$env.config = ($env.config | upsert hooks {
    env_change: {
        PWD: [
            {|before, after| update_zellij_tab }
        ]
    }
})

# Initial tab name setup
update_zellij_tab
