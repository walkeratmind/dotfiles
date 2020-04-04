#!/bin/bash
## Exports path here for both zsh and bash

# Rust Path
export PATH="$PATH: $HOME/.cargo/bin"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/rakesh/development_tools/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/rakesh/development_tools/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/rakesh/development_tools/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/rakesh/development_tools/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export ANDROID_HOME=~/Android/sdk
