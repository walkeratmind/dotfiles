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

# Install modulo for forms. See here https://espanso.org/docs/install/linux/#installing-modulo
function install_modulo() {
	# Make sure to have the $HOME/Apps directory
	mkdir -p $HOME/Apps

	# Download the latest Modulo AppImage in the $HOME/Apps
	wget https://github.com/federico-terzi/modulo/releases/latest/download/modulo-x86_64.AppImage -O $HOME/Apps/modulo.AppImage

	# Make it executable:
	chmod u+x $HOME/Apps/modulo.AppImage

	# Create a link to make modulo available as "modulo"
	sudo ln -s $HOME/Apps/modulo.AppImage /usr/bin/modulo
}

install_modulo
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
