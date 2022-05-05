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
install iterm2
install visual-studio-code
install alacritty

install brave-browser	
