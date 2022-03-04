#!bin/bash


# Install espanso if not
function install_espanso() {
  which espanso

  if [ $? -ne 0 ]; then
    echo "Installing: espanso"
      sudo apt update
      sudo apt install libxtst6 libxdo3 xclip libnotify-bin
      curl -L https://github.com/federico-terzi/espanso/releases/download/v0.7.3/espanso-linux.tar.gz | tar -xz -C /tmp/
      sudo mv /tmp/espanso /usr/local/bin/espanso
      espanso start
  fi
}

install_espanso

function install {
  which $1 &> /dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1} ${2}"
        espanso install $1 $2
    echo "---------------------------"
  else
    echo "Already installed: ${1}"
    echo "---------------------------"
  fi
}

espanso install all-emojis
espanso install gitmojis
espanso install basic-emojis

install dadjoke
espanso install lorem

espanso install cht
espanso install wttr
