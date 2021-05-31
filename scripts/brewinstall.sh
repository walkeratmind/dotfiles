#!/bin/bash

function install {
  which $1 &> /dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1}..."
    brew install $1
    echo "----------------------------"
  else
    echo "Already installed: ${1}"
    echo "----------------------------"
  fi
}

#install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Basics
# install awscli
# install docker.io
# install chromium-browser

install htop
install jq
install nmap
install tmux
install tree
install vim
install neovim
install httpie
install xclip
install zsh
install youtube-dl
install unzip
install nnn

install awscli
install docker

install go
install cmake
install maven

# Rust tools

# ------------------------------------------------------------
#                 Built on Rust
# ------------------------------------------------------------

install rust
# install starship
install exa                 # ls with more power
install fd                  # faster than find
install ripgrep             # grep with power
install sd                  # find and replace, faster sed
install bat                 # cat in a bat
install procs               # ps
install tokei               # generate code stats, no. of lines, comments
install hyperfine           # benchmark your code
install gitui               # Interactive terminal git ui
install tealdeer            # shorter man : tldr
install git-delta
install navi                # interactive cheatsheet tool for CLI
install bandwhich           # display network stats
install jql                 # Smart JQ, json parser
install grex                # get regex
install just                # improved Makefile with justfile
install mdcat               # markdown reader for terminal
install mdbook              # Generate book from .md
install dog                 # dns client
install rustscan            # Faster Nmap Scanning with Rust

brew tap tgotwig/linux-dust && brew install dust    # du alternative


install deno

# ------------------------------------------------------------

# Built on Golang
install qrcp
# install jid
brew install glow

install nvm

# Android Tools
install kotlin
install scrcpy

# install zeal for offline documentation
# https://zealdocs.org/download.html
# install zeal

# Image processing
install feh
install jpegoptim
install optipng
# best image viewer
install feh

install mpv

# Fun stuff
install cowsay
install figlet
install lolcat
