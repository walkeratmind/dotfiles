#!/bin/bash

echo "📦 Installing nvm"
export NVM_DIR="$HOME/.nvm" && (
  git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
  cd "$NVM_DIR"
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
) && \. "$NVM_DIR/nvm.sh"

source ~/.bashrc

nvm install node
nvm install-latest-npm

# Required for Hugo
npm install -g autoprefixer postcss-cli

npm install -g yarn
# yo - yeoman
npm install -g yo
# Simplified option for > man
npm install -g tldr
npm install -g alacritty-themes
# Check links in markdown alive (200 OK) or dead
npm install -g markdown-link-check
