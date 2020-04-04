#!/bin/bash

#
# tricks
# handy shortcuts more verbose with colors

# systemctl force color
export SYSTEMD_COLORS=1

# grep
# alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}
# using ripgrep instead of gnu grep
# https://github.com/BurntSushi/ripgrep
alias grep=rg

# ls
# https://the.exa.website
alias l='exa -F'
alias ll='exa -lF'
alias la='exa -aF'
alias lla='exa -aFl'
alias lg='exa -aFl --git'
alias ltree='exa --long --tree'

# df hide tmpfs
alias df='df -h -x tmpfs '

# cat as bat is less than more
>/dev/null which bat && alias less='bat'

# lazy conf
function run { chmod +x "$@" && ./$1; }
function mkcd { mkdir -p "$1" && cd "$1"; }

alias rsync="rsync --progress"


# function rm {
#     # interactive rm
#     /usr/bin/rm -v $@
#     if [[ "$?" == '1' ]]; then
#         echo -n "use 'rmdir'? "
#         read reply
#         if [[ $reply == "y" || $reply == "Y" || $reply == "" ]]; then
#             /usr/bin/rmdir $@
#         fi

#         echo -n "use 'rm -rf' (yes/no)? "
#         read reply
#         if [[ $reply == "yes" ]]; then
#             /usr/bin/rm -rfv $@
#             return $?
#         fi
#     fi
# }


function mic2speaker {
    ## loudSpeak with lots of echos

    # wanna save it too
    # arecord -f cd - | tee output.wav | aplay -
    # Note: Remember spaces in between [ ]
    if [[ $1 == "-r" || $1 == "--record" ]]; then
        str="rec_.$(date +%F%t%k_%M_%S).wav"
        arecord -f cd - | tee "${str}" | aplay -
        echo "Saved at:${PWD}"
    elif [[ $1 == '-h' || $1 == "--help" ]]; then
        echo "USAGE"
        echo "      mic2speaker: to just loud speak"
        echo "      mic2speaker -r || mic2speaker --r: to record and speak"
    else
        arecord -f cd - | aplay -
    fi
    
}