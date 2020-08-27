#!/bin/bash

mkdir -p ~/apps
cd ~/apps

curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
chmod u+x nvim.appimage

