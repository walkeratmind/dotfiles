#!/bin/bash
## Exports path here for both zsh and bash

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

# alias for latest nvim
alias nvim="~/apps/nvim.appimage"
alias joplin="~/.joplin/Joplin.AppImage"
