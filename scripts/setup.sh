#!/bin/bash

bash ./symlink.sh
bash ./aptinstall.sh

# Run all programs/ install scripts
for f in programs/*.sh; do bash "$f" -H; done


# Get all upgrades
sudo apt upgrade -y

# See our bash changes
source ~/.bashrc

# Fun hello
figlet "May GNU/Linux Shine on You ..." | lolcat --spread 2 --animate --duration 1
