# History control
# don't use duplicate lines or lines starting with space
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
# append to the history file instead of overwrite
shopt -s histappend

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi


# Show contents of dir after action
function cd () {
    builtin cd "$1"
    ls -ACF
}

# Golang install or upgrade
function getgolang () {
    sudo rm -rf /usr/local/go
    wget -q -P tmp/ https://dl.google.com/go/go"$@".linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf tmp/go"$@".linux-amd64.tar.gz
    rm -rf tmp/
    go version
}

# GHCLI install or upgrade
function getghcli () {
    wget -q -P tmp/ https://github.com/cli/cli/releases/download/v"$@"/gh_"$@"_linux_amd64.deb
    cd tmp/ && sudo dpkg -i gh_"$@"_linux_amd64.deb
    cd .. && rm -rf tmp/
    gh --version
}

# Hugo install or upgrade
function gethugo () {
    wget -q -P tmp/ https://github.com/gohugoio/hugo/releases/download/v"$@"/hugo_extended_"$@"_Linux-64bit.tar.gz
    tar xf tmp/hugo_extended_"$@"_Linux-64bit.tar.gz -C tmp/
    sudo mv -f tmp/hugo /usr/local/bin/
    rm -rf tmp/
    hugo version
}

# Hugo site from exampleSite in themes/
function hugotheme () {
    HUGO_THEME="$1" hugo "${@:2}" --themesDir ../.. -v
}

# Add GitLab remote to cwd git
function glab () {
    git remote set-url origin --add git@gitlab.com:victoriadrake/"${PWD##*/}".git
    git remote -v
}

# Markdown link check in a folder, recursive
function mlc () {
    find $1 -name \*.md -exec markdown-link-check -p {} \;
}

# Go
export PATH=$PATH:/usr/local/bin:/usr/local/go/bin:~/.local/bin:$GOPATH/bin
export GOPATH=~/go

# Vim for life
export EDITOR=/usr/bin/vim
export VISUAL=io.elementary.code

# Bash completion
source ~/.git-completion.bash

# Color prompt
export TERM=xterm-256color

# Colours have names too. Stolen from @victoriadrake who stole from @tomnomnom -> who stole it from Arch wiki
txtblk='\[\e[0;30m\]' # Black - Regular
txtred='\[\e[0;31m\]' # Red
txtgrn='\[\e[0;32m\]' # Green
txtylw='\[\e[0;93m\]' # Yellow
txtblu='\[\e[0;34m\]' # Blue
txtpur='\[\e[0;35m\]' # Purple
txtcyn='\[\e[0;96m\]' # Cyan
txtwht='\[\e[0;37m\]' # White
bldblk='\[\e[1;30m\]' # Black - Bold
bldred='\[\e[1;31m\]' # Red
bldgrn='\[\e[1;32m\]' # Green
bldylw='\[\e[1;33m\]' # Yellow
bldblu='\[\e[1;34m\]' # Blue
bldpur='\[\e[1;35m\]' # Purple
bldcyn='\[\e[1;36m\]' # Cyan
bldwht='\[\e[1;37m\]' # White
unkblk='\[\e[4;30m\]' # Black - Underline
undred='\[\e[4;31m\]' # Red
undgrn='\[\e[4;32m\]' # Green
undylw='\[\e[4;33m\]' # Yellow
undblu='\[\e[4;34m\]' # Blue
undpur='\[\e[4;35m\]' # Purple
undcyn='\[\e[4;36m\]' # Cyan
undwht='\[\e[4;37m\]' # White
bakblk='\[\e[40m\]'   # Black - Background
bakred='\[\e[41m\]'   # Red
badgrn='\[\e[42m\]'   # Green
bakylw='\[\e[43m\]'   # Yellow
bakblu='\[\e[44m\]'   # Blue
bakpur='\[\e[45m\]'   # Purple
bakcyn='\[\e[46m\]'   # Cyan
bakwht='\[\e[47m\]'   # White
txtrst='\[\e[0m\]'    # Text Reset

# Prompt colours
atC="${txtpur}"
nameC="${txtblu}"
hostC="${txtpur}"
pathC="${txtcyn}"
gitC="${txtpur}"
pointerC="${txtwht}"
normalC="${txtrst}"

# Red pointer for root
if [ "${UID}" -eq "0" ]; then
    pointerC="${txtred}"
fi

gitBranch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

export PS1="${pathC}\w ${gitC}\$(gitBranch) ${pointerC}\$${normalC} "

# Use powerline-shell prompt
function _update_ps1() {
    PS1=$(powerline-shell $?)
}

if [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

