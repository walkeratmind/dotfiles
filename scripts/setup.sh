#!/bin/bash

bash ./symlink.sh
# bash ./aptinstall.sh
bash ./brewinstall.sh

# Run all programs/ install scripts
for f in programs/*.sh; do bash "$f" -H; done


# Get all upgrades
sudo apt upgrade -y

# See our bash changes
source ~/.bashrc

# Fun hello
figlet "May Linux be Merciful on You ..." | lolcat --spread 2 --animate --duration 1
