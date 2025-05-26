use '~/.cache/starship/init.nu'

# atuin
source ~/.local/share/atuin/init.nu


# Define a function that updates the Zellij tab name
def zellij_tab_name_update [] {
    # Only do this if running inside Zellij
    if $env.ZELLIJ != "" {
        let tab_name = ""

        # Attempt to detect if we're in a Git repo
        try {
            # This succeeds if we are in a Git repository
            git rev-parse --is-inside-work-tree | ignore

            # If no error, construct the tab name from the repo root and subdirectory
            let repo_name = (git rev-parse --show-toplevel | path basename)
            let git_prefix = (git rev-parse --show-prefix | str trim)
            let tab_name = ($repo_name + '/' + $git_prefix | str trim -c '/')
        } catch {
            # If not in a Git repo, use the directory name
            let current_dir = $env.PWD
            if $current_dir == $env.HOME {
                let tab_name = "~"
            } else {
                let tab_name = ($current_dir | path basename)
            }
        }

        # Rename the Zellij tab (ignore any output)
        zellij action rename-tab $tab_name | ignore
    }
}

# Override the built-in `cd` command so the tab name updates automatically
def cd [
    path?
] {
    if $path == "" {
        builtin cd
    } else {
        builtin cd $path
    }
    # After changing directories, update the Zellij tab name
    zellij_tab_name_update
}

# Run once on shell start to set the initial tab name
# zellij_tab_name_update

