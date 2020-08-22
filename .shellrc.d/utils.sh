#!/bin/bash


#
# My personal preference
#

# My ways
# alias startx='startx &> ~/.xlog'

# Stupid stuffs
alias rc.d='systemctl'
alias git-unstage='git reset'

export SPARK_HOME="/usr/share/apache-spark/"
export PYSPARK_SUBMIT_ARGS="--master local[4]"
alias pyspark="/usr/share/apache-spark/bin/pyspark"
alias pyspark-notebook="IPYTHON_OPTS='notebook' /usr/share/apache-spark/bin/pyspark"

# mount
# alias mount="mount | column -t | less -S"

# gdb
alias gdb="gdb -q"

# WINE is the standard env variable
export WIN="~/.wine/dosdevices/c:"
alias c:="cd $WIN"


function xdg-give-me-damn-exec {
    (( $# == 0 )) && {
        echo "Usage:"
        echo "  $ xdg-give-me-damn-exec text/x-python"
        return
    }

    local name=$(xdg-mime query default $1)

    for prefix in ~/.local /user /usr/local; do
        local mime="$prefix/share/applications/$name"
        if [[ -f "$mime" ]]; then
            grep "^Exec" $mime
            return
        fi
    done
    >&2 echo "GTFO no mime"
    return 9000
}


function mtp-device-enable-udev {
    local LSUSB=($(lsusb))
    for ((i=0; i < ${#LSUSB}; i++)); do
        echo -e "$i\t${LSUSB[i]}"
    done
    # read -r choice
    # re insert your device
}


function readlink {
    if [[ -t 1 ]]; then
        while read data; do
            args+="$data"
        done
        /usr/bin/readlink ${args[*]}
	    return
    fi

    if [[ $# -gt 0 ]]; then
        /usr/bin/readlink $@
    fi
}


# function emacs {
#     # if [[ -t 1 ]]; then
#     #     while read data; do
#     #         args+="$data"
#     #     done
#     #     echo "data: ${args[*]}"
#     #     # /usr/bin/emacs ${args[*]}
# 	#     return
#     # fi

#     ##
#     ### emacs wrapper for mulitplexing
#     if [[ $# -eq 0 ]]; then
#         /usr/bin/emacs # "emacs" is function, will cause recursion
#         return
#     fi

#     args=($*)
#     # TIP: add '-' arguement for opening new emacs session
#     for ((i=0; i <= ${#args}; i++)); do
#         local a=${args[i]}
#         # NOTE: -c create frame; -nw: no-window
#         if [[ ${a:0:1} == '-' && $a != '-c' ]]; then
#             # TIPS: -nw will not work with setsid use '&'
#             /usr/bin/emacs ${args[*]}
#             return
#         fi
#     done

#     setsid emacsclient -n -a /usr/bin/emacs ${args[*]}
# }


# function nemo {
#     ##
#     ### nemo (file browser) wrapper
#     if [[ $# -eq 0 ]]; then
#         setsid /usr/bin/nemo . # "nemo" is function, will cause recursion
#     else
#         setsid /usr/bin/nemo $@
#     fi
# }


# function nautilus {
#     ##
#     ### nemo (file browser) wrapper
#     if [[ $# -eq 0 ]]; then
#         setsid /usr/bin/nautilus . # "nemo" is function, will cause recursion
#     else
#         setsid /usr/bin/nautilus $@
#     fi
# }


function bluetooth-turn-it-on {
    sudo modprobe btusb
    sudo modprobe bluetooth
    sudo systemctl start bluetooth.service
    setsid blueman-manager
}


function dlna {
    cp /etc/minidlna.conf /tmp/dlna.conf
    echo "media_dir=${1:-$PWD}" >> /tmp/dlna.conf

    sudo minidlnad -R -d -f /tmp/dlna.conf
}


# function frontmacs {
#     env HOME=/home/$USER/.emacs.d/frontmacs emacs
# }


# function doomemacs {
#     env HOME=/home/$USER/.emacs.d/doom emacs
# }


function randpass {
    #random password of desired length
    < /dev/urandom tr -dc '_A-Z-a-z-0-9+-~!@#$%^&*()_+=-'| head -c${1:-16};echo;
    # openssl rand -base64 |head -c${1:-16};echo;
}


function audible {
    (( $# == 0 )) && {
        echo "Usage:"
        echo "  $ audible admhelper"
        return
    }
    # git clone https://github.com/inAudible-NG/audible-activator
    # you will need activation key extractor
    wget -c "http://cdl.audible.com/cgi-bin/aw_assemble_title_dynamic.aa?$(cat $1)" -O "/tmp/$1.aax"
    ffmpeg -y -activation_bytes $KEY_AUDIBLE -i "/tmp/$1.aax" -c:a copy -vn "$1.m4a"
}
