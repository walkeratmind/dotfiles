#!/bin/bash

function install {
  which $1 &>/dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1}..."
    brew install --cask $1
    echo "----------------------------"
  else
    echo "Already installed: ${1}"
    echo "----------------------------"
  fi
}

#install brew if not exists
if [ brew -ne 0 ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "-----------------------------"
else
  echo "Already installed brew"
  echo "-----------------------------"
fi

# Install GUI Apps

# Basic Apps
install brave-browser

install alfred
install fig

install webtorrent
install free-download-manager
install notion
install calibre
install skim

install iterm2
install visual-studio-code
install alacritty
install pgadmin4
install postman
install insomnia
install dbeaver-community
# install hiddenbar
install flameshot
install blender
install godot

install itsycal
install stats
# install sublime-text

# tiling window manager: https://github.com/koekeishiya/yabai
brew install koekeishiya/formulae/yabai
# hotkeys for macos (required for yabai to set shortcuts): https://github.com/koekeishiya/skhd
brew install koekeishiya/formulae/skhd

install pika
