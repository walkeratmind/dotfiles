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
install rust
# install starship
install exa
install fd
install bat
install ripgrep
install procs
install sd
install tokei
install hyperfine
install gitui
install tealdeer

install nvm
install deno

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


brew install fx
brew install glow
brew install bandwhich
