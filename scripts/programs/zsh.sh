#!/bin/bash


# install zsh via curl
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash)"

# install powerlevel10k theme
# https://github.com/romkatv/powerlevel10k
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/themes/powerlevel10k

# install starship
echo "🦀 Installing starship..."
curl -fsSL https://starship.rs/install.sh | bash
