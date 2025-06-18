#!/bin/bash
#Checking if using armv6
if [ ! -z "$(cat /proc/cpuinfo | grep ARMv6)" ];then
  error "armv6 cpu not supported"
fi
sudo apt install curl git build-essential cmake autoconf -y
if ! command -v node > /dev/null ; then
echo -e "\033[0;31mnode not found. Installing now...\e[39m"
#Install nvm manager:
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash || error "Failed to install nvm!"
source "${DIRECTORY}/api"
if [ "$arch" == 32 ];then
  #armhf, so patch nvm script to forcibly use armhf
  sed -i 's/^  nvm_echo "${NVM_ARCH}"/  NVM_ARCH=armv7l ; nvm_echo "${NVM_ARCH}"/g' "$NVM_DIR/nvm.sh"
fi

#remove original nvm stuff from bashrc
sed -i '/NVM_DIR/d' ~/.bashrc
# Create nvm initialisation script in another file for easier uninstallation
# Credit: https://www.growingwiththeweb.com/2018/01/slow-nvm-init.html
echo 'if [ -s "$HOME/.nvm/nvm.sh" ] && [ ! "$(type -t __init_nvm)" = function ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
  declare -a __node_commands=("nvm" "node" "npm" "yarn" "gulp" "grunt" "webpack")
  function __init_nvm() {
    for i in "${__node_commands[@]}"; do unalias $i; done
    . "$NVM_DIR"/nvm.sh
    unset __node_commands
    unset -f __init_nvm
  }
  for i in "${__node_commands[@]}"; do alias $i="__init_nvm && "$i; done
fi' > ~/.node_bashrc
echo ". ~/.node_bashrc" >> ~/.bashrc
# One time use, since `source ~/.bashrc` not working
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# Install latest nodejs
nvm install node || error "Failed to install node.js with nvm!"
source ~/.bashrc
fi
sudo rm /usr/share/applications/qt*
mkdir ~/apps
git clone --recurse-submodules -j8 git://github.com/Stremio/stremio-shell.git ~/apps/stremio
cd ~/apps/stremio
qmake
make -f release.makefile
cp ./server.js ./build/ && ln -s "$(which node)" ./build/node
sudo curl -o /usr/share/icons/hicolor/scalable/apps/stremio.png --url https://www.stremio.com/website/stremio-logo-small.png
sudo tee -a /usr/share/applications/stremio.desktop>/dev/null <<EOT
[Desktop Entry]
Name=Stremio
Comment=Stremio
Exec=~/apps/stremio/build/stremio
Icon=stremio
Terminal=false
Type=Application
StartupNotify=true
EOT
