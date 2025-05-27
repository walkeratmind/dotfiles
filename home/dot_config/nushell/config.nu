use '~/.cache/starship/init.nu'

# atuin
source ~/.local/share/atuin/init.nu


# Define a function that updates the Zellij tab name only if inside a Git repo
def zellij_tab_name_update [] {
    # Only do this if running inside Zellij
    if $env.ZELLIJ != "" {
        # Try to detect if we're in a Git repo
        try {
            git rev-parse --is-inside-work-tree | ignore

            # If no error, construct the tab name from the repo root and subdirectory
            let repo_name = (git rev-parse --show-toplevel | path basename)
            let git_prefix = (git rev-parse --show-prefix | str trim)
            let tab_name = ($repo_name + '/' + $git_prefix | str trim -c '/')

            # Rename the Zellij tab (ignore any output)
            zellij action rename-tab $tab_name | ignore
        } catch {
            # Not in a Git repo, do nothing (don't update tab name)
        }
    }
}

# Override the built-in `cd` command so the tab name updates automatically
def cd [path?] {
    if $path == "" {
        ^cd
    } else {
        ^cd $path
    }
    # After changing directories, update the Zellij tab name only if in Git repo
    zellij_tab_name_update
}

# Run once on shell start to set the initial tab name
# zellij_tab_name_update

