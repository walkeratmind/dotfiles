
$env.config.show_banner = false   # hide nushell banner

$env.config.history = {
  file_format: sqlite
  max_size: 1_000_000
  sync_on_enter: true
  isolation: true
}

# homebrew
$env.PATH = ($env.PATH | split row (char esep) | prepend '/opt/homebrew/bin')

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
$env.config.buffer_editor = "hx"

# Config Path
$env.XDG_CONFIG_HOME = ($env.HOME + "/.config")

# Rust Path (append to PATH)
$env.PATH = ($env.PATH | append ($env.HOME + "/.cargo/bin"))

# Manage python environments
$env.VENVPATH = ($env.HOME + "/development_tools/pyenv")

# Flutter Env (append to PATH)
$env.PATH = ($env.PATH | append ($env.HOME + "/fvm/default/bin"))

# Additional tools
$env.PATH = ($env.PATH | append ($env.HOME + "/development_tools"))
$env.PATH = ($env.PATH | append ($env.HOME + "/.emacs.d/bin"))
# ------------------------------------------------------------
# ANDROID SDK Setup
# ------------------------------------------------------------

$env.ANDROID_SDK_ROOT = ($env.HOME + "/Library/Android/sdk")
$env.PATH = ($env.PATH | append ($env.ANDROID_SDK_ROOT + "/emulator"))
$env.PATH = ($env.PATH | append ($env.ANDROID_SDK_ROOT + "/tools"))
$env.PATH = ($env.PATH | append ($env.ANDROID_SDK_ROOT + "/bin"))
$env.PATH = ($env.PATH | append ($env.ANDROID_SDK_ROOT + "/platform-tools"))

# ------------------------------------------------------------
# COMMON FUNCTIONS AND OTHER RC SETTINGS
# ------------------------------------------------------------

# Markdown link check in a folder (recursive)
# (Requires that "markdown-link-check" is available in your PATH)
def mlc [folder: string] {
    fd $folder -e "*.md" | each { |it| markdown-link-check $it }
}


# ------------------------------------------------------------
# Go Language Setup
# ------------------------------------------------------------

$env.GOPATH = ($env.HOME + "/development_tools/go")
# Append Go-related paths (adjust as needed)
$env.PATH = ($env.PATH | append "/usr/local/bin" | append "/usr/local/go/bin"
   | append ($env.HOME + "/.local/bin") | append ($env.GOPATH + "/bin"))

# ------------------------------------------------------------
# Node Version Manager (NVM)
# ------------------------------------------------------------
# Nushell cannot directly source bash scripts. The following lines are
# noted from your zsh config; you might consider running nvm from bash,
# or use a nushell-compatible wrapper.
#
# $env.NVM_DIR = ($env.HOME + "/.nvm")
# if (test -e ($env.NVM_DIR + "/nvm.sh")) { source ($env.NVM_DIR + "/nvm.sh") }
# if (test -e ($env.NVM_DIR + "/bash_completion")) { source ($env.NVM_DIR + "/bash_completion") }

# ------------------------------------------------------------
# Yarn & SDKMAN Setup
# ------------------------------------------------------------

# Yarn: prepend its bin directory to PATH
$env.PATH = $env.PATH | append ($env.HOME + "/.yarn/bin")

# SDKMAN: as with nvm, sourcing the init script isn’t directly supported in Nushell.
# $env.SDKMAN_DIR = ($env.HOME + "/.sdkman")
# if (test -e ($env.SDKMAN_DIR + "/bin/sdkman-init.sh")) { source ($env.SDKMAN_DIR + "/bin/sdkman-init.sh") }

# ------------------------------------------------------------
# Amplify CLI & Ripgrep Config
# ------------------------------------------------------------

# Amplify CLI binary installer
$env.PATH = $env.PATH | append ($env.HOME + "/.amplify/bin")

# Ripgrep configuration
$env.RIPGREP_CONFIG_PATH = ($env.HOME + "/.config/.ripgreprc")

# ------------------------------------------------------------
# FNM (Fast Node Manager) Setup
# ------------------------------------------------------------
# In zsh you eval the output of fnm env; in Nushell you may need to run a command
# and update environment variables accordingly. The following is a placeholder.
#
# run fnm env --use-on-cd | each { update-env $it }
#
# Adjust this to your workflow or consider running fnm commands directly
