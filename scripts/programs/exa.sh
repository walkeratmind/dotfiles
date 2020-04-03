#!/bin/bash

curl https://sh.rustup.rs -sSf | sh
wget -c https://the.exa.website/releases/exa-linux-x86_64-0.9.0.zip
unzip exa-linux-x86_64-0.9.0.zip
rm exa-linux-x86_64-0.9.0.zip
sudo mv exa-linux-x86_64 /usr/local/bin/exa
