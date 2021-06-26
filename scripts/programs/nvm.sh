#!/bin/bash

# echo "📦 Installing nvm"
# export NVM_DIR="$HOME/.nvm" && (
#   git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
#   cd "$NVM_DIR"
#   git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
# ) && \. "$NVM_DIR/nvm.sh"

# source ~/.bashrc

function install {
  which $1 &>/dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1}..."
    yarn global $1
    echo "----------------------------"
  else
    echo "Already installed: ${1}"
    echo "----------------------------"
  fi
}

nvm install node
nvm install-latest-npm

# Required for Hugo
install autoprefixer postcss-cli

# npm install -g yarn     # install from brew
# yo - yeoman
install yo

# jhipster for Java Hipsters and Junkies to quickly setup the projects
install generator-jhipster

# Simplified option for > man
#npm install -g tldr
# install -g alacritty-themes

# Check links in markdown alive (200 OK) or dead
install markdown-link-check

echo "👓 Installing Sass"
install sass sass-lint
