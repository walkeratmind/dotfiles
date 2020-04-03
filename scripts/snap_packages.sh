
function install {
  which $1 &> /dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1} ${2}"
    sudo snap install $1 $2
    echo "---------------------------"
  else
    echo "Already installed: ${1}"
    echo "---------------------------"
  fi
}


# install code --classic
install codium --classic
# install atom --classic
install sublime-text --classic
install postman
install insomnia
# install go --classic
install node --classic
install ruby --classic
install kotlin --classic
install node-red
install octave

# monitor tools
# install htop
install gnome-system-monitor

# Network Tools
# install nmap

#browser 
install chromium
# install firefox

# install notable
install libreoffice

# Social Apps
install skype --classic
install discord
install slack --classic

# Media
install vlc
install inkscape
install krita
install blender --classic
install shotcut
install ffmpeg
# install obs-studio
install gimp
