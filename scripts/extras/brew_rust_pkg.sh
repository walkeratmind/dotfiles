function install {
  which $1 &>/dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1} ${2}"
    brew install $1 $2
    echo "---------------------------"
  else
    echo "Already installed: ${1}"
    echo "---------------------------"
  fi
}

# Check here https://github.com/matu3ba/awesome-cli-rust/

# https://github.com/bvaisvil/zenith
cargo install --git https://github.com/bvaisvil/zenith.git

install ytop
install bottom
install procs

install watchexec # execute command when file changes https://github.com/watchexec/watchexec
install xsv       # csv on terminal https://github.com/BurntSushi/xsv

# Get Latest from the source
install nushell # https://github.com/nushell/nushell

install fnm # nodejs verison manager (replace nvm) https://github.com/Schniz/fnm

install skim           # fuzzy file finder  https://github.com/lotabout/skim
cargo install kondo-ui # clears node_modules and other libs https://github.com/tbillington/kondo

install zola  # static site generator https://github.com/getzola/zola
install broot # navigate files faster from terminal https://github.com/Canop/broot

install websocat # https://github.com/vi/websocat

install miniserve # server files over http https://github.com/svenstaro/miniserve

install t-rec # record your terminal https://github.com/sassman/t-rec-rs

install zellij # terminal multiplexer https://github.com/zellij-org/zellij

install just # make alternative https://github.com/casey/just

install git-interactive-rebase-tool # https://github.com/MitMaro/git-interactive-rebase-tool

install pastel # color https://github.com/sharkdp/pastel

install gping # ping with graph https://github.com/orf/gping

# install topgrade # upgrade anything https://github.com/r-darwish/topgrade

install hexyl # command line hex viewer for files https://github.com/sharkdp/hexyl

# install volta # js tools manager https://github.com/volta-cli/volta
