
function install {
  which $1 &> /dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1} ${2}"
    flatpak install $1 $2
  else
    echo "Already installed: ${1}"
  fi
}

install flathub com.github.tchx84.Flatseal
install flathub com.github.taiko2k.tauonmb

# Developer Tools
# install flathub com.jgraph.drawio.desktop
#install org.processing.processingide
install flathub org.zealdocs.Zeal
#install org.godotengine.Godot
# install flathub cc.arduino.arduinoide
#install org.octave.Octave

# Latex Editor
# install net.xm1math.Texmaker

#install com.github.fabiocolacio.marker

install flathub io.dbeaver.DBeaverCommunity
install flathub com.axosoft.GitKraken

# install flathub com.getpostman.Postman
install flathub rest.insomnia.Insomnia
# install flathub org.filezillaproject.Filezilla

# install flathub org.fritzing.Fritzing

install flathub com.github.alecaddd.sequeler

# -------------
# Essential
install flathub org.gimp.GIMP
install flathub org.blender.Blender
install org.inkscape.Inkscape
install flathub org.kde.krita

install flathub com.obsproject.Studio

install flathub com.github.phase1geo.minder
install flathub md.obsidian.Obsidian
install flathub net.cozic.joplin_desktop

# Keyboard Centric note
# flatpak install flathub org.gabmus.notorious

# install flathub org.videolan.VLC
install flathub org.shotcut.Shotcut

 # install flathub com.github.alainm23.byte
 # flatpak install flathub com.github.needleandthread.vocal
install flathub com.github.robertsanseries.ciano

install flathub org.kde.kdenlive

# install flathub org.qbittorrent.qBittorrent
install com.calibre_ebook.calibre

# Social
#install flathub org.telegram.desktop
# install flathub com.slack.Slack
install flathub com.discordapp.Discord

# install flathub org.jamovi.jamovi
 # install flathub org.remmina.Remmina

# EPUB Reader
install flathub com.github.johnfactotum.Foliate

# Wallpaper Manager
install flathub com.github.calo001.fondo
install flathub org.gabmus.hydrapaper

install flathub com.github.alainm23.planner

install flathub com.github.gijsgoudzwaard.image-optimizer

install flathub io.webtorrent.WebTorrent

install flathub org.flameshot.Flameshot
install flathub com.uploadedlobster.peek
install flathub com.belmoussaoui.Decoder


install flathub com.github.subhadeepjasu.pebbles
install flathub com.github.liferooter.textpieces
install flathub org.onlyoffice.desktopeditors
