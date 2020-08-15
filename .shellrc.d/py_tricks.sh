#!bin/bash


function py {
    ##
    ### python wrapper for multiplexer
    if [[ $# -eq 0 ]]; then
        # detect virtual env
        local VER=$(python -c "import sys; print('{v.major}.{v.minor}'.format(v=sys.version_info))")
        export PYTHONPATH="$(dirname `which python`)/../lib/python${VER}/site-packages/"
        echo "venv: $PYTHONPATH"

        # ps -p$PPID | grep gnome-terminal > /dev/null && xterm -ls "bpython" && return
        which bpython && bpython || python
        return
    fi
    python $@
}

function activate() {
    source "$VENVPATH/$1/bin/activate"
}

function venvlist() {
    echo "Python Venv List:"
    echo "-------------------"
    for f in ${VENVPATH}/*; do
        [ -d "$f" ] || continue
        # echo $f # for debugging
        echo "$f"
    done
    unset f
}

function mkpyenv {
    if [ -z "$1" ]; then
        echo "WTF, enter a valid virtualenv name..."
        echo "---------------------------------------"
        echo "USAGE:"
        echo "  create virtual env in current dir: makepyenv venv"
        echo "  create virtual env in $VENVPATH: makepyenv 'env_name'"
    elif [ $1 == "venv" ]; then
        python3 -m venv venv
        echo "venv name: venv"
        echo "virtualenv at: $PWD/venv"
        echo "activate 'venv' env cmd: source venv/bin/activate  "
        echo "---------------------------------------"
    # elif [[ $1 == '-h' || $1 == "--help" ]]; then
    #     echo "USAGE"
    #     echo "  create virtual env in current dir: makepyenv venv"
    #     echo "  create virtual env in $VENVPATH: makepyenv 'env_name'"
    else
        python3 -m venv $VENVPATH/$1
        echo "venv name: $1"
        echo "virtualenv at: $VENVPATH/$1"
        echo "activate '$1' env cmd: activate $1 "
        echo "---------------------------------------"
    fi

}
