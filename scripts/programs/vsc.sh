#!/bin/bash

# https://code.visualstudio.com/docs/setup/linux
echo "⌨️ Installing VSCode"
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt install -y apt-transport-https
sudo apt update
sudo apt install -y code
rm microsoft.gpg
ln -s $(pwd)/../../.config/Code/User/settings.json $HOME/.config/Code/User/settings.json
function install {
  name="${1}"
  code --install-extension ${name} --force
}

#vs code theme
install teabyii.ayu
# sync settins file
install Shan.code-settings-sync
install EditorConfig.EditorConfig
install dbaeumer.vscode-eslint
install ms-python.python
install ms-vscode.cpptools
install ms-dotnettools.csharp
install esbenp.prettier-vscode
install eamodio.gitlens
install ritwickdey.LiveServer
install octref.vetur
install PKief.material-icon-theme
install ms-vscode.Go
install redhat.vscode-yaml
install formulahendry.auto-rename-tag
install formulahendry.auto-close-tag

install batisteo.vscode-django
install bibhasdn.django-html
install coenraads.bracket-pair-colorizer
install davidanson.vscode-markdownlint
install glen-84.sass-lint
install ms-python.python
install ms-vscode-remote.remote-containers
install ms-vscode.Go
install yzhang.markdown-all-in-one

