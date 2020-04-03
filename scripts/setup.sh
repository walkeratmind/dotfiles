
#!/bin/bash

./symlink.sh
./aptinstall.sh

# Run all programs/ install scripts
for f in programs/*.sh; do bash "$f" -H; done

# ./desktop.sh
# ./snap_packages.sh

# Get all upgrades
sudo apt upgrade -y

# See our bash changes
source ~/.bashrc

# Fun hello
figlet "... and we're done for now!" | lolcat