# init

sudo apt update && sudo apt upgrade

##
# GIT
##

git config --global user.email "cam@cystark.com.au"
git config --global user.name "Cam Stark"
git config --global credential.helper store
git config --global core.editor "vim"
sudo apt -y install tig


##
# ZSH
##

sudo apt -y install zsh


##
# EDITOR
##

# vim
sudo apt -y install vim
sudo apt -y install neovim
npm install -g neovim


##
# LANGUAGES
##

# python
sudo apt -y install python-is-python3 
sudo apt -y install python3-pip 

# nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
# might need a restart?
nvm install v16.19.0 
nvm alias default v16.19.0 

# Ruby
sudo apt -y install ruby

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# java
sudo apt -y install default-jdk
sudo apt -y install default-jre
sudo add-apt-repository ppa:webupd8team/java
sudo apt update
sudo apt -y install oracle-java11-installer
sudo apt -y install jq

# perl
curl -L http://xrl.us/installperlnix | bash
sudo apt -y install p7zip


##
# DB
##

# postgres
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get -y install postgresql

# pgadmin
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg
sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
sudo apt -y install pgadmin4 


##
# DOCKER
##

# docker - https://linuxhint.com/install-docker-on-pop_os/
sudo apt update
sudo apt install  ca-certificates  curl  gnupg  lsb-release
echo  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu   $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y
#sudo systemctl status docker


# Docker compose
# https://devimalplanet.com/how-to-install-docker-compose-on-linux-pop-_os-19-04
sudo curl \
   -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" \
   -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

##
# VIRTUALBOX
##

# virtualbox
sudo apt -y install virtualbox 
sudo apt -y install virtualbox—ext–pack 

# vagrant
curl -O https://releases.hashicorp.com/vagrant/2.2.9/vagrant_2.2.9_x86_64.deb
sudo apt -y install ./vagrant_2.2.9_x86_64.deb 
sudo mkdir /etc/vbox;
# https://stackoverflow.com/questions/35942754/how-can-i-save-username-and-password-in-git
sudo echo -n "\n\n* 10.0.0.0/8 192.168.0.0/16\n\n* 2001::/64" networks.conf


##
# DRIVER
##

# wacom driver
sudo sh -c "apt-get update && apt-get install xserver-xorg-input-wacom$(dpkg -S $(which Xorg) | grep -Eo -- "-hwe-[^:]*")"
sudo apt-get install autoconf pkg-config make xutils-dev libtool xserver-xorg-dev$(dpkg -S $(which Xorg) | grep -Eo -- "-hwe-[^:]*") libx11-dev libxi-dev libxrandr-dev libxinerama-dev libudev-dev


##
# VPN
##

# Nord VPN
sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)
nordvpn login
nordvpn connect
nordvpn set autoconnect on

# adjust settings

##
# 1Pass
##

# (https://support.1password.com/install-linux/)
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
sudo apt update && sudo apt -y install 1password 

##
# Other Tools
##

# Gnome
sudo apt -y install gnome-tweaks 
sudo apt -y install ubuntu-restricted-extras 

# Clipboard
sudo apt -y install xclip
sudo apt -y install xsel

# Other Tools
sudo apt -y install ack
sudo apt -y install wget
sudo apt -y install ffmpeg
sudo apt -y install xdotool
sudo apt -y install webp

# Tmux
sudo apt -y install tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# FZF
# sudo apt -y install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
sudo ~/.fzf/install

# PWGen
sudo apt -y install pwgen

# Ripgrep
sudo apt -y install ripgrep

# Shyaml
pip install shyaml

# AG
sudo apt -y install silversearcher-ag

# Trash Cli
sudo apt -y install trash-cli

# espanso
# https://github.com/espanso/espanso/
# text expander
if [ $XDG_SESSION_TYPE = "x11" ]; then
 wget https://github.com/federico-terzi/espanso/releases/download/v2.1.8/espanso-debian-wayland-amd64.deb
 sudo apt install ./espanso-debian-x11-amd64.deb
 rm -rf ./espanso-debian-wayland-amd64.deb
else
  echo "Need to be X11 or Wayland for Espanso to work"
fi

# kmonad
# keybroad layout modifier
# https://github.com/kmonad/kmonad
# wget -qO- https://get.haskellstack.org/ | sh - # do not need. download binaries
# instead below. Update with neweset kmonad version
wget https://github.com/kmonad/kmonad/releases/download/0.4.1/kmonad-0.4.1-linux kmonad
chmod +x kmonad
sudo mv kmonad /usr/bin/local

# splatmoji
# emoji picker
# https://github.com/cspeterson/splatmoji
# https://hsps.in/post/amazing-emoji-keyboard-in-linux/
wget https://github.com/cspeterson/splatmoji/releases/download/v1.2.0/splatmoji_1.2.0_all.deb
sudo dpkg -i splatmoji_1.2.0_all.deb

# color picker
sudo apt -y install gpick

# screen record
# https://github.com/hzbd/kazam
sudo apt install kazam

# Normcap OCR dependencies
# https://github.com/dynobo/normcap
sudo apt -y install build-essential tesseract-ocr tesseract-ocr-eng libtesseract-dev libleptonica-dev wl-clipboard
pip install normcap


##
# SNAP
# - not sure if I want to use snap.. but some programs dont have deb packages
##

sudo apt-get install snap
sudo snap install rambox
sudo snap install signal-desktop


##
# FLATPAK
##

flatpak install --assumeyes flathub \
  flathub org.flameshot.Flameshot \
  flathub com.spotify.Client \
  # pop os comes with this already
  # flathub com.github.hluk.copyq \
  flathub md.obsidian.Obsidian \
  flathub net.ankiweb.Anki \
  flathub com.calibre_ebook.calibre \
  flathub org.mozilla.firefox \
  flathub com.usebottles.bottles \
  flathub com.valvesoftware.Steam \
  flathub com.visualstudio.code \
  flathub org.blender.Blender \
  flathub org.godotengine.Godot \
  flathub org.libretro.RetroArch \
  flathub org.videolan.VLC\
  flathub dbeaver.DBeaverCommunity \
  flathub org.gnome.DejaDup \
  flathub com.getpostman.Postman

##
# Might come back to
##

# Guake. like the F12 drop down terminal
# sudo apt -y install pinstall guake 

