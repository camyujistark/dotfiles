# init
sudo apt update && sudo apt upgrade

sudo apt -y install ack
sudo apt -y install ffmpeg
sudo apt -y install fzf

# vim
sudo apt -y install vim
sudo apt -y install neovim
npm install -g neovim


sudo apt -y install default-jdk
sudo apt -y install default-jre
sudo add-apt-repository ppa:webupd8team/java
sudo apt update
sudo apt -y install oracle-java11-installer
sudo apt -y install jq
curl -L http://xrl.us/installperlnix | bash
sudo apt -y install p7zip
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get -y install postgresql
sudo apt -y install pwgen
sudo apt -y install ripgrep
sudo apt -y install ruby
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
pip install shyaml
sudo apt -y install silversearcher-ag
sudo apt -y install tig
sudo apt -y install tmux
# Tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

sudo apt -y install trash-cli
sudo apt -y install webp
sudo apt -y install wget
sudo apt -y install zsh
sudo apt -y install xclip
sudo apt -y install xsel
sudo apt -y install rofi
sudo apt -y install xdotool
# sudo apt install "chrome-cli"
# sudo apt install "gi
# fzf

git config --global credential.helper store
git config --global core.editor "vim"

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
sudo ~/.fzf/install

# 1pass
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
sudo apt update && sudo apt -y install 1password 

# Spacecadet
sudo apt -y install libboost-dev libudev-dev libyaml-cpp-dev libevdev-dev cmake build-essential
cd ~
mkdir -p .modern-space-cadet/src # create a src folder to clone and compile our programs
cd .modern-space-cadet/src
sudo add-apt-repository ppa:deafmute/interception
sudo apt install -y interception-tools
sudo vim /etc/udevmon.yaml
sudo vim /etc/systemd/system/udevmon.service
git clone https://gitlab.com/interception/linux/plugins/dual-function-keys
vim ~/.modern-space-cadet/dual-function-keys.yaml
sudo systemctl enable --now udevmon
sudo systemctl start udevmon
sudo systemctl status udevmon

# Docker - https://linuxhint.com/install-docker-on-pop_os/
sudo apt update
sudo apt install  ca-certificates  curl  gnupg  lsb-release
echo  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu   $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y
#sudo systemctl status docker


# espanso
if [ $XDG_SESSION_TYPE = "x11" ]; then
 wget https://github.com/federico-terzi/espanso/releases/download/v2.1.8/espanso-debian-wayland-amd64.deb
 sudo apt install ./espanso-debian-x11-amd64.deb
 rm -rf ./espanso-debian-wayland-amd64.deb
else
  echo "Need to be X11 or Wayland for Espanso to work"
fi


# kmonad
# wget -qO- https://get.haskellstack.org/ | sh - # do not need. download binaries
# instead below. Update with neweset kmonad version
wget https://github.com/kmonad/kmonad/releases/download/0.4.1/kmonad-0.4.1-linux kmonad
chmod +x kmonad
sudo mv kmonad /usr/bin/local


# splatmoji
# https://hsps.in/post/amazing-emoji-keyboard-in-linux/
wget https://github.com/cspeterson/splatmoji/releases/download/v1.2.0/splatmoji_1.2.0_all.deb
sudo dpkg -i splatmoji_1.2.0_all.deb

# color picker
sudo apt -y install gpick

# OCR dependencies
sudo apt -y install build-essential tesseract-ocr tesseract-ocr-eng libtesseract-dev libleptonica-dev wl-clipboard
pip install normcap

# nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
# might need a restart?
nvm install v16.19.0 
nvm alias default v16.19.0 

# pgadmin
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg
sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
sudo apt -y install pgadmin4 

# guake
sudo apt -y install pinstall guake 

# virtualbox
sudo apt -y install virtualbox 
sudo apt -y install virtualbox—ext–pack 
curl -O https://releases.hashicorp.com/vagrant/2.2.9/vagrant_2.2.9_x86_64.deb
sudo apt -y install ./vagrant_2.2.9_x86_64.deb 
sudo mkdir /etc/vbox;
# https://stackoverflow.com/questions/35942754/how-can-i-save-username-and-password-in-git
sudo echo -n "\n\n* 10.0.0.0/8 192.168.0.0/16\n\n* 2001::/64" networks.conf


# python
sudo apt -y install python-is-python3 
sudo apt -y install python3-pip 

# Gnome
sudo apt -y install gnome-tweaks 
sudo apt -y install ubuntu-restricted-extras 

# snap
sudo apt-get install snap
sudo snap install rambox
sudo snap install signal-desktop

# Keyboard macros - autokey
sudo apt install autokey-gtk


# flatpak
flatpak install --assumeyes flathub \
  flathub org.flameshot.Flameshot \
  flathub com.spotify.Client \
  flathub com.github.hluk.copyq \
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
