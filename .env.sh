#!/bin/bash


# ------------------------------------------------------------
# - Title: .common_rc.sh
# - Author: Rakesh Niraula
# - Date: 2020-08-17 11:03:31
# ------------------------------------------------------------



# ------------------------------------------------------------
        # Exports path here for both zsh and bash
# ------------------------------------------------------------

# Rust Path
export PATH="$PATH: $HOME/.cargo/bin"

# Manage python environments
export VENVPATH="$HOME/development_tools/pyenv"

# Flutter Env
export PATH="$PATH:$HOME/development_tools/flutter/bin"


# alias for project folder
alias plab="cd $HOME/project_files"


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('$HOME/development_tools/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/development_tools/anaconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/development_tools/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/development_tools/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export ANDROID_HOME=~/Android/Sdk
export PATH="$PATH:$ANDROID_HOME/platform-tools"

# =====================================================


# ------------------------------------------------------------
#         COMMON FUNCTIONS AND OTHER RC FILES
# ------------------------------------------------------------


# Show contents of dir after action
function cd () {
    builtin cd "$1"
    ls -ACF
}

# Markdown link check in a folder, recursive
function mlc () {
    find $1 -name \*.md -exec markdown-link-check -p {} \;
}

# Does Vim makes developers life better?
export EDITOR=/usr/bin/vim
export VISUAL=gedit

# Go
export GOPATH=$HOME/development_tools/go
export PATH=$PATH:/usr/local/bin:/usr/local/go/bin:~/.local/bin:$GOPATH/bin

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion