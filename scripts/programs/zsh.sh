#!/bin/bash


# install zsh via curl
echo "Installing ZSH..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# install powerlevel10k theme
# https://github.com/romkatv/powerlevel10k
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/themes/powerlevel10k

# install starship
echo "🦀 Installing starship..."
sh -c "$(curl -fsSL https://starship.rs/install.sh)"


