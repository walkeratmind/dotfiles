#!/bin/bash

# Up from scripts dir
cd ..

dotfilesDir=$(pwd)

function linkDotfile {
  dest="${HOME}/${2}/${1}"
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
linkDotfile .git-completion.bash
linkDotfile .shellrc.d
linkDotfile .shellrc

linkDotfile .zshrc
linkDotfile .p10k.zsh

linkDotfile .aliases
linkDotfile .common_path.sh
linkDotfile .get_cli_tools.sh

linkDotfile .curlrc

linkDotfile alacritty.yml .config/alacritty

# mkdir -p $dotfilesDir/.vim/bundle
# cd $dotfilesDir/.vim/bundle
# git clone git://github.com/VundleVim/Vundle.vim.git
# vim +PluginInstall +qall
