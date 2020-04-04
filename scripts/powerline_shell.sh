#!/bin/bash

mkdir -p ~/src/github.com/powerline/
cd ~/src/github.com/
git clone https://github.com/b-ryan/powerline-shell
cd powerline-shell
sudo python3 setup.py install