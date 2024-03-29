#!/bin/bash

# Up from scripts dir
cd ..

dotfilesDir=$(pwd)

function linkDotfile {
  dest="${HOME}/${1}"
  dateStr=$(date +%Y-%m-%d-%H%M)

  if [ -h "${dest}" ]; then
    # Existing symlink
    echo "Removing existing symlink: ${dest}"
    rm ${dest}

  elif [ -f "${dest}" ]; then
    # Existing file
    echo "Backing up existing file: ${dest}"
    mv ${dest}{,.${dateStr}}

  elif [ -d "${dest}" ]; then
    # Existing dir
    echo "Backing up existing dir: ${dest}"
    mv ${dest}{,.${dateStr}}
  fi

  echo "Creating new symlink: ${dest}"
  ln -s ${dotfilesDir}/${1} ${dest}
}

# function linkDotFolder {
#   dest = "$HOME/${1}"
#   dateStr=$(date +%Y-%m-%d-%H%M)

#   echo "Creating new symlink: ${dest}"
#   ln -s ${dotfilesDir}/${1} ${dest}
# }

linkDotfile .vimrc
linkDotfile .tmux.conf
linkDotfile .bashrc
linkDotfile .bash_profile
linkDotfile .gitconfig
linkDotfile .gitmessage
linkDotfile .git-completion.sh
linkDotfile .shellrc.d

linkDotfile .zshrc

linkDotfile .aliases
linkDotfile .env

linkDotfile .curlrc

# create symlink for all folder present in .config in ~/.config (Note: Don't symlink the .config dir as it contains other programs config too)
# for f in ./.config/*/* ; do
# 	if [ -f $f ]; then
# 		linkDotfile "$f";
# 	fi
# done

# for f in ./.config/* ; do
# 	if [ -f $f ]; then
# 		linkDotfile "$f";
# 	fi
# done

# set .config folder in $HOME folder like and
# symlink the folders from .config

mkdir -p $HOME/.config/alacritty
linkDotfile .config/alacritty/alacritty.yml

mkdir -p $HOME/.config/zellij
linkDotfile .config/zellij

linkDotfile .config/starship.toml

linkDotfile .config/espanso
linkDotfile .config/doom

mkdir -p $HOME/.config/fish
linkDotfile .config/fish/config.fish

mkdir -p $HOME/.config/nvim
linkDotfile .config/nvim/init.vim

linkDotfile .config/nvim/lua

linkDotfile .config/nvim/plugin

# mkdir -p $dotfilesDir/.vim/bundle
# cd $dotfilesDir/.vim/bundle
# git clone git://github.com/VundleVim/Vundle.vim.git
# vim +PluginInstall +qall
