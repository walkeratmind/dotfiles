# Advanced zellij integration for Nushell

# Check if we're in a zellij session
export def "zellij is-active" [] {
    $env.ZELLIJ? != null
}

# Smart command runner that mimics tmux behavior
export def zr [
    --floating(-f)          # Run in floating pane
    --in-place(-i)         # Run in-place
    --keep(-k)             # Keep pane open
    --cwd(-c): path        # Working directory
    --name(-n): string     # Custom name
    ...command: string     # Command to run
] {
    if not (zellij is-active) {
        print "Not in a zellij session"
        return
    }
    
    let cmd_str = ($command | str join " ")
    if ($cmd_str | is-empty) {
        print "Usage: zr [options] <command>"
        return
    }
    
    let pane_name = if ($name | is-empty) { $cmd_str } else { $name }
    
    mut zellij_args = [run --name $pane_name]
    
    if $floating { $zellij_args = ($zellij_args | append "--floating") }
    if $in_place { $zellij_args = ($zellij_args | append "--in-place") }
    if not $keep { $zellij_args = ($zellij_args | append "--close-on-exit") }
    if ($cwd | is-not-empty) { $zellij_args = ($zellij_args | append [--cwd $cwd] | flatten) }
    
    # Use nushell to run the command
    $zellij_args = ($zellij_args | append [-- nu -c $cmd_str] | flatten)
    
    ^zellij ...$zellij_args
}

# Project-specific runners
export def "zr dev" [...args: string] {
    let common_dev_commands = [
        "pnpm run dev"
        "npm run dev" 
        "yarn dev"
        "cargo run"
        "go run ."
        "python main.py"
        "node index.js"
    ]
    
    if ($args | is-empty) {
        # Try to detect project type and run appropriate command
        let cmd = if ("package.json" | path exists) {
            if ("pnpm-lock.yaml" | path exists) { "pnpm run dev" }
            else if ("yarn.lock" | path exists) { "yarn dev" }
            else { "pnpm run dev" }
        } else if ("Cargo.toml" | path exists) {
            "cargo run"
        } else if ("go.mod" | path exists) {
            "go run ."
        } else {
            print "No recognized project type found"
            return
        }
        
        print $"Running: ($cmd)"
        zr --name "dev" $cmd
    } else {
        let cmd = ($args | str join " ")
        zr --name "dev" $cmd
    }
}

# Quick test runner
export def "zr test" [...args: string] {
    let cmd = if ($args | is-empty) {
        if ("package.json" | path exists) { "pnpm test" }
        else if ("Cargo.toml" | path exists) { "cargo test" }
        else if ("go.mod" | path exists) { "go test ./..." }
        else { 
            print "No recognized project type for testing"
            return
        }
    } else {
        ($args | str join " ")
    }
    
    zr --name "test" --floating $cmd
}

# Build runner
export def "zr build" [...args: string] {
    let cmd = if ($args | is-empty) {
        if ("package.json" | path exists) { "pnpm run build" }
        else if ("Cargo.toml" | path exists) { "cargo build" }
        else if ("go.mod" | path exists) { "go build" }
        else {
            print "No recognized project type for building"
            return
        }
    } else {
        ($args | str join " ")
    }
    
    zr --name "build" $cmd
}
