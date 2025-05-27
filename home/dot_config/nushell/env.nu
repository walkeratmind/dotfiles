
$env.config.show_banner = false   # hide nushell banner

let temp_dir = (
    if $env.XDG_RUNTIME_DIR? != null { $env.XDG_RUNTIME_DIR }  # Preferred on Linux
    else if $env.TMPDIR? != null { $env.TMPDIR }               # macOS/Linux alternative
    else if $env.TMP? != null { $env.TMP }                     # Windows alternative
    else { "/tmp" }                                            # Default fallback
)

export-env { load-env {
    XDG_DATA_HOME: ($env.HOME | path join ".local" "share")
    XDG_CONFIG_HOME: ($env.HOME | path join ".config")
    XDG_STATE_HOME: ($env.HOME | path join ".local" "state")
    XDG_CACHE_HOME: ($env.HOME | path join ".cache")
    XDG_DOCUMENTS_DIR: ($env.HOME | path join "documents")
    XDG_DOWNLOAD_DIR: ($env.HOME | path join "downloads")
    XDG_MUSIC_DIR: ($env.HOME | path join "Extras" "Music")
    XDG_PICTURES_DIR: ($env.HOME | path join "Pictures")
    XDG_VIDEOS_DIR: ($env.HOME | path join "Extras" "Videos")
}}

export-env {
    $env.GIT_REPOS_HOME = ($env.HOME | path join "project_lab")
    $env.GIST_HOME = ($env.HOME | path join "project_lab/gists")

    load-env {
        DOTFILES_GIT_DIR: ($env.GIT_REPOS_HOME | path join "github.com" "walkeratmind" "dotfiles")
        DOTFILES_WORKTREE: $env.HOME
    }
}

$env.TERMINFO_DIRS = [
    ($env.XDG_DATA_HOME | path join "terminfo"),
    "/usr/share/terminfo",
]

$env.GEM_VERSION = "3.0.0"

export-env { load-env {
    ANDROID_SDK_ROOT: ($env.HOME | path join "Library/Android/sdk")
    CARGO_HOME: ($env.XDG_DATA_HOME | path join "cargo")
    CLANG_HOME: ($env.XDG_DATA_HOME | path join "clang-15")
    DOOMDIR: ($env.XDG_CONFIG_HOME | path join "doom")
    EMACS_HOME: ($env.HOME | path join ".emacs.d")
    GNUPGHOME: ($env.XDG_DATA_HOME | path join "gnupg")
    GOPATH: ($env.XDG_DATA_HOME | path join "go")
    GTK2_RC_FILES: ($env.XDG_CONFIG_HOME | path join "gtk-2.0" "gtkrc")
    HISTFILE: ($env.XDG_STATE_HOME | path join "bash" "history")
    JUPYTER_CONFIG_DIR: ($env.XDG_CONFIG_HOME | path join "jupyter")
    KERAS_HOME: ($env.XDG_STATE_HOME | path join "keras")
    LESSHISTFILE: ($env.XDG_CACHE_HOME | path join "less" "history")
    NODE_REPL_HISTORY: ($env.XDG_DATA_HOME | path join "node_repl_history")
    NPM_CONFIG_USERCONFIG: ($env.XDG_CONFIG_HOME | path join "npm" "npmrc")
    NUPM_CACHE: ($env.XDG_CACHE_HOME | path join "nupm")
    NUPM_HOME: ($env.XDG_DATA_HOME | path join "nupm")
    PASSWORD_STORE_DIR: ($env.XDG_DATA_HOME | path join "pass")
    PYTHONSTARTUP: ($env.XDG_CONFIG_HOME | path join "python" "pythonrc")
    QT_QPA_PLATFORMTHEME: "qt5ct"
    QUICKEMU_HOME: ($env.XDG_DATA_HOME | path join "quickemu")
    RUBY_HOME: ($env.XDG_DATA_HOME | path join "gem" "ruby" $env.GEM_VERSION)
    RUSTUP_HOME: ($env.XDG_CONFIG_HOME | path join "rustup")
    SQLITE_HISTORY: ($env.XDG_CACHE_HOME | path join "sqlite_history")
    SSH_AGENT_TIMEOUT: 300
    SSH_KEYS_HOME: ($env.HOME | path join ".ssh" "keys")
    TERMINFO: ($env.XDG_DATA_HOME | path join "terminfo")
    WORKON_HOME: ($env.XDG_DATA_HOME | path join "virtualenvs")
    XINITRC: ($env.XDG_CONFIG_HOME | path join "X11" "xinitrc")
    ZDOTDIR: ($env.XDG_CONFIG_HOME | path join "zsh")
    ZELLIJ_LAYOUTS_HOME: ($env.GIT_REPOS_HOME | path join "github.com" "walkeratmind" "zellij-layouts" "layouts")
    _JAVA_OPTIONS: $"-Djava.util.prefs.userRoot=($env.XDG_CONFIG_HOME | path join java)"
    _Z_DATA: ($env.XDG_DATA_HOME | path join "z")
    RIPGREP_CONFIG_PATH: ($env.XDG_CONFIG_HOME | path join ".ripgreprc")
    VENVPATH: ($env.HOME + "/development_tools/pyenv")
}}

mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu


# ------------------------------------------------------------
# .env for Nushell
# Author: Rakesh Niraula (original zshrc/.env)
# Date: 2025-02-14 (adapted for Nushell)
# ------------------------------------------------------------

# ------------------------------------------------------------
# Environment Variables & PATH Setup
# ------------------------------------------------------------

# Editor settings
$env.EDITOR = 'nvim'
$env.VISUAL = $env.EDITOR
$env.config.buffer_editor = "nvim"

def --env _set_manpager [pager: string] {
    $env.MANPAGER = match $pager {
        "bat" => {
            const BAT_PAGER_CMD = r#'sh -c 'sed -u -e "s/\x1B\[[0-9;]*m//g; s/.\x08//g" | {{CMD}} -p -lman''#

            let bats = which bat batcat
            if ($bats | is-empty) {
                error make {
                    msg: $"(ansi red_bold)pager_not_found(ansi reset)",
                    label: {
                        text: $"could not find pager for (ansi cyan)bat(ansi reset)",
                        span: (metadata $pager).span,
                    },
                    help: $"install either (ansi purple)bat(ansi reset) or (ansi purple)batcat(ansi reset)"
                }
            }

            $BAT_PAGER_CMD | str replace "{{CMD}}" $bats.0.path
        },
        "vim" => r#'/bin/sh -c "col -b | vim -u NONE -c 'set ft=man ts=8 nomod nolist nonu noma' -"'#,
        "nvim" => "nvim +Man!",
        "less" => {
            $env.LESS_TERMCAP_mb = (tput bold; tput setaf 2)  # green
            $env.LESS_TERMCAP_md = (tput bold; tput setaf 2)  # green
            $env.LESS_TERMCAP_so = (tput bold; tput rev; tput setaf 3)  # yellow
            $env.LESS_TERMCAP_se = (tput smul; tput sgr0)
            $env.LESS_TERMCAP_us = (tput bold; tput bold; tput setaf 1)  # red
            $env.LESS_TERMCAP_me = (tput sgr0)
            "less"
        },
        _ => {
            error make {
                msg: $"(ansi red_bold)unknown_pager(ansi reset)",
                label: {
                    text: $"($pager) is not supported",
                    span: (metadata $pager).span,
                },
                help: $"use one of (ansi cyan)bat(ansi reset), (ansi cyan)vim(ansi reset), (ansi cyan)nvim(ansi reset) or (ansi cyan)less(ansi reset)"
            }
         }
    }
}

_set_manpager "bat"

$env.FZF_DEFAULT_OPTS = "
--bind ctrl-d:half-page-down
--bind ctrl-u:half-page-up
--bind shift-right:preview-half-page-down
--bind shift-left:preview-half-page-up
--bind shift-down:preview-down
--bind shift-up:preview-up
--preview-window right,80%
"


use std "path add"
path add ($env.XDG_DATA_HOME | path join "npm" "bin")
path add ($env.CARGO_HOME | path join "bin")
path add ($env.CLANG_HOME | path join "bin")
path add ($env.GOPATH | path join "bin")
path add ($env.EMACS_HOME | path join "bin")
path add ($env.RUBY_HOME | path join "bin")
path add ($env.NUPM_HOME | path join "scripts")
path add ($env.HOME | path join ".local" "bin")
path add "/opt/homebrew/bin"
path add ($env.HOME | path join "fvm/default/bin") # Flutter Env 
# ------------------------------------------------------------
# ANDROID SDK Setup
# ------------------------------------------------------------
path add ($env.ANDROID_SDK_ROOT | path join "emulator")
path add ($env.ANDROID_SDK_ROOT | path join "tools")
path add ($env.ANDROID_SDK_ROOT | path join "bin")
path add ($env.ANDROID_SDK_ROOT | path join "platform-tools")
path add ($env.HOME | path join ".yarn" "bin")
# Amplify CLI binary installer
path add ($env.HOME | path join ".amplify" "bin")


# Markdown link check in a folder (recursive)
# (Requires that "markdown-link-check" is available in your PATH)
def mlc [folder: string] {
    fd $folder -e "*.md" | each { |it| markdown-link-check $it }
}


# Node Version Manager (NVM)
# ------------------------------------------------------------
# Nushell cannot directly source bash scripts. The following lines are
# noted from your zsh config; you might consider running nvm from bash,
# or use a nushell-compatible wrapper.
#
# $env.NVM_DIR = ($env.HOME + "/.nvm")
# if (test -e ($env.NVM_DIR + "/nvm.sh")) { source ($env.NVM_DIR + "/nvm.sh") }
# if (test -e ($env.NVM_DIR + "/bash_completion")) { source ($env.NVM_DIR + "/bash_completion") }

# SDKMAN: as with nvm, sourcing the init script isn’t directly supported in Nushell.
# $env.SDKMAN_DIR = ($env.HOME + "/.sdkman")
# if (test -e ($env.SDKMAN_DIR + "/bin/sdkman-init.sh")) { source ($env.SDKMAN_DIR + "/bin/sdkman-init.sh") }

$env.PATH = ($env.PATH | uniq)

# ------------------------------------------------------------
# FNM (Fast Node Manager) Setup
# ------------------------------------------------------------
# In zsh you eval the output of fnm env; in Nushell you may need to run a command
# and update environment variables accordingly. The following is a placeholder.
#
# run fnm env --use-on-cd | each { update-env $it }

$env.NU_LIB_DIRS = [
    ($env.NUPM_HOME | path join "modules"),
    ($nu.default-config-dir | path join "overlays")
    ($nu.config-path | path dirname | path join "modules")
]

$env.NU_PLUGIN_DIRS = [
    ($env.CARGO_HOME | path join "bin")
    ($env.NUPM_HOME | path join "plugins/bin")
]

$env.SHELL = $nu.current-exe

$env.GPG_TTY = (tty)
