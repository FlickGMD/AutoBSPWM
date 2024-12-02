#!/bin/bash
if [[ $(whoami) == "root" ]] || [[ $(id -u) -eq 0 ]]; then
  echo -e "\n[!] Este script no puede ser ejecutado como root"
  echo -e "Ejecutar: exit"
  echo -e "Ejecutar ./$0"
  exit 1
fi

function handler(){
  echo -e "\n[!] Saliendo..."
  exit 1
}
trap handler INT
RUTA=$(pwd)
usuario=$(whoami)
# ACTUALIZAMOS EL PROGRAMA EN BASE A NUESTRO SISTEMA OPERATIVO
if [[ $(hostname) == *"kali"* ]]; then
  echo -e "\n[*] Actualizando sistema kali."
  sudo apt update
  sudo apt full-upgrade -y 
  echo -e "\n[*] Actualizacion finalizada."
elif [[ $(hostname) == *"parrot"* ]]; then
  echo -e "\n[*] Actualizando sistema kali."
  sudo apt update
  sudo parrot-upgrade -y
  echo -e "\n[*] Actualizacion finalizada."
else
  echo -e "\n[!] $(hostname): NO ENCONTRADO."
  exit 1
fi


# INSTALANDO LOS PRINCIPALES 
sudo apt install bspwm sxhkd polybar rofi -y
sudo apt-get install libxcb-randr0-dev libxcb-xtest0-dev libxcb-xinerama0-dev libxcb-shape0-dev libxcb-xkb-dev libpcre3-dev -y 
sudo apt install xcb -y
sudo apt  install build-essential git vim xcb libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev libxcb-shape0-de -y
sudo apt install -y python3-venv
sudo apt install glxinfo -y
sudo apt install npm -y

# INSTALANDO BSPWM Y SU REPO

# PICOM INSTALACION
echo -e "\n[*] Obteniendo picom"
git clone https://github.com/ibhagwan/picom.git

# DEPENDENCIAS DE MESSON
sudo apt install meson libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev libpcre3-dev libpcre3 libevdev-dev uthash-dev libev-dev libx11-xcb-dev libxcb-glx0-dev libev-dev -y

cd picom
git submodule update --init --recursive
meson --buildtype=release . build
ninja -C build
sudo ninja -C build install

# FINALIZAMOS LA INSTALACION DE PICOM

# ULTIMA VERSIÓN DE KITTY A INSTALAR
kitty=$(7z l kitty-0.37.0-arm64.txz | tail -n 3 | head -n 1 | awk 'NF{print $NF}')
cd kitty
7z x kitty-0.37.0-arm64.txz
sudo tar -xf $kitty
cd ..
# INSTALACIÓN DE NVIM
nvim=$(7z l nvim-linux64.tar.gz | tail -n 3 | head -n 1 | awk 'NF{print $NF}')
cd nvim
7z x nvim-linux64.tar.gz 
sudo tar -xf $nvim
git clone https://github.com/NvChad/starter ~/.config/nvim
if [[ -f ~/.config/nvim/lua/configs/lspconfig.lua ]]; then
  rm ~/.config/nvim/lua/configs/lspconfig.lua
  mv lsp/lspconfig.lua ~/.config/nvim/lua/configs/lspconfig.lua
fi

# INSTALAMOS LA P10K DE LA ZSH :)
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
rm ~/.p10k.zsh
cp /p10kuser/.p10k.zsh /home/$usuario/

# LO INSTALAMOS PERO PA ROOT
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >> /root/.zshrc
rm ~/root/p10k.zsh
sudo cp /p10kroot/.p10k.zsh /root/

python3 -m venv .venv
source .venv/bin/activate
.venv/bin/pip3 install pywal

#-----------------------------#
# FIX THE NVIM PROBLEM        #
#-----------------------------#
#pylint fails to install: python3 failed with exit code 1 and signal 0.
sudo apt install -y python3-venv
