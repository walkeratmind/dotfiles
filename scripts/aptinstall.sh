#!/bin/bash

# sudo add-apt-repository ppa:kubuntu-ppa/backports
sudo apt update && sudo apt full-upgrade -y

function install {
  which $1 &> /dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1}..."
    sudo apt install $1
    echo "----------------------------"
  else
    echo "Already installed: ${1}"
    echo "----------------------------"
  fi
}

# Basics
# install awscli
# install docker.io
# install chromium-browser

install file
install git
install htop
install jq
install nmap
install openvpn
install tmux
install tree
install vim
install neovim
install httpie
install xclip
install default-jdk
install gparted
install zsh

# install python tools
install sqlitebrowser

# install zeal for offline documentation
# https://zealdocs.org/download.html
# install zeal


# install for optimizing cpu usage and never worry for these two
install preload
# install for optimizing battery life
install tlp

# Image processing
# install gimp
install feh
install jpegoptim
install optipng
# best image viewer
install feh

# Fun stuff
install figlet
install lolcat

install mpv
install vlc
