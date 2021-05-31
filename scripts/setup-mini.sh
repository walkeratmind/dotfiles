#!/bin/bash

bash ./symlink.sh
# bash ./aptinstall.sh

# Run all programs/ install scripts
# for f in programs/*.sh; do bash "$f" -H; done

sudo apt install zsh
sudo apt install xclip
sudo apt install vim

# install c
sudo apt install gcc
sudo apt install g++
sudo apt install cmake

# install rust
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# install golang

bash ./programs/zsh.sh
bash ./programs/nvm.sh
bash ./programs/vundle.sh
bash ./programs/python.sh


# Get all upgrades
# sudo apt upgrade -y

# See our bash changes
source ~/.bashrc

echo "Setup complete."
