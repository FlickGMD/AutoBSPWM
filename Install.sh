#!/bin/bash
ruta=$(realpath $0 | rev | cut -d'/' -f2- | rev)
distro=$(lsb_release -d | grep -oP "Parrot|Kali")
usuario=$USER 

update_system(){
  echo -e "\n${bright_cyan}[+]${end} ${bright_white}Actualizando sistema:${end} ${bright_magenta}$distro....${end}"
  if [[ $distro == 'Parrot' ]]; then
    sudo apt update && sudo parrot-upgrade -y &>/dev/null
    if [[ $(echo $?) -ne 0  ]]; then
      wget https://deb.parrot.sh/parrot/pool/main/p/parrot-archive-keyring/parrot-archive-keyring_2024.12_all.deb &>/dev/null
      sudo dpkg -i parrot-archive-keyring_2024.12_all.deb || sudo dpkg -i *.deb &>/dev/null # .deb 
    fi
  elif [[ $distro == 'Kali' ]]; then
    sudo apt update 
    sudo apt upgrade -y 
  fi
}

function install_fetch(){
  cd $ruta
  sudo apt install git cmake build-essential -y 
  git clone https://github.com/fastfetch-cli/fastfetch
  cd fastfetch
  cmake -B build -DCMAKE_BUILD_TYPE=Release
  cmake --build build --target fastfetch -j$(nproc)
  sudo cp build/fastfetch /usr/local/bin/
  cd $ruta 
  rm -rf fastfetch 2>/dev/null 
}

install_bspwm(){
  cd $ruta
  echo -e "\n${bright_cyan}[+]${bright_white} Instalando bspwm...${end}"
  sudo apt install bspwm -y &>/dev/null
  cp -r ./config/bspwm/ ~/.config/  
  # Instalando dependencias que requieran los scripts de bspwmrc
  sudo apt install feh -y &>/dev/null
  sudo apt install imagemagick cmatrix -y &>/dev/null
  sudo apt install neofetch -y &>/dev/null
  sudo apt install fastfetch -y &>/dev/null || install_fetch
  mkdir -p ~/Imágenes
  ./font.sh
  cp wallpapers/*.jpg ~/Imágenes
  mkdir -p ~/Imágenes/capturas
  
  # Buscador de máquinas 
  sudo apt install coreutils util-linux npm nodejs bc moreutils translate-shell -y &>/dev/null
  sudo apt install node-js-beautify -y &>/dev/null 
  sudo cp -r scripts/s4vimachines.sh/ /opt 
  sudo chown -R $usuario:$usuario /opt/s4vimachines.sh 

  # scripts para reconocimiento
  sudo cp -r ./scripts/whichSystem/* /opt/ 
  sudo chown -R $usuario:$usuario /opt/Linux/
  sudo chown -R $usuario:$usuario /opt/Python/
}

install_sxhkd(){
  echo -e "\n${bright_cyan}[+]${bright_white} Instalando sxhkd...${end}"
  cp -r ./config/sxhkd/ ~/.config/
  sudo apt install flameshot i3lock-fancy xclip moreutils mesa-utils scrub coreutils -y &>/dev/null
  mkdir -p ~/.config/bin/
  touch ~/.config/bin/target

}

install_p10k(){
  echo -e "\n${bright_cyan}[+]${bright_white} Instalando la PowerLevel10k...${end}"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k &>/dev/null
  cp ./config/PowerLevel10k/.p10k.zsh /home/$usuario
  sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k &>/dev/null
  sudo cp ./config/PowerLevel10k/.p10k.zsh /root/ 
}

install_kitty(){
  cd $ruta
  echo -e "\n${bright_cyan}[+]${bright_white} Instalando kitty...${end}"
  sudo apt install kitty -y &>/dev/null
  cp -r ./config/kitty/ ~/.config/
  sudo cp -r ./config/kitty/ /root/.config/
}

install_zsh(){
  echo -e "\n${bright_cyan}[+]${bright_white} Instalando la zsh...${end}"
  sudo apt install zsh zsh-syntax-highlighting zsh-autosuggestions -y &>/dev/null
  sudo usermod --shell /usr/bin/zsh $usuario &>/dev/null
  sudo usermod --shell /usr/bin/zsh root &>/dev/null 
  cp ./config/zsh/.zshrc ~/.zshrc 
  sed "s|~/.config/bin/target|/home/$usuario/.config/bin/target|" ./config/zsh/.zshrc > root-zsh
  sudo rm /root/.zshrc 2>/dev/null
  sudo mv root-zsh /root
  sudo mv /root/root-zsh /root/.zshrc
  sudo cp -r ./config/zsh-sudo /usr/share/
}

install_fzf(){
  echo -e "\n${bright_cyan}[+]${bright_white} Instalando fzf...${end}"
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all &>/dev/null

  sudo git clone --depth 1 https://github.com/junegunn/fzf.git /root/.fzf
  sudo /root/.fzf/install --all &>/dev/null
} 

install_polybar(){
  cd $ruta
  echo -e "\n${bright_cyan}[+]${bright_white} Instalando la polybar...${end}"
  sudo apt install polybar -y &>/dev/null
  cp -r ./config/polybar/ ~/.config/
}

install_picom(){
  cd $ruta
  echo -e "\n${bright_cyan}[+]${bright_white} Instalando el compositor picom...${end}"
  sudo apt install meson libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev libpcre2-dev libevdev-dev uthash-dev libev-dev libx11-xcb-dev libxcb-glx0-dev libev-dev libpcre3-dev -y &>/dev/null
  sudo apt install cmake -y &>/dev/null

  [[ -d "picom" ]] && rm -rf picom
  if ! sudo apt install picom -y &>/dev/null; then
    # Instalamos picom desde los repositorios de git 
    git clone https://github.com/ibhagwan/picom.git &>/dev/null
    cd picom &>/dev/null
    git submodule update --init --recursive &>/dev/null 
    meson setup --buildtype=release . build &>/dev/null 
    ninja -C build &>/dev/null 
    sudo ninja -C build install &>/dev/null 
    cd ..
    rm -rf picom
  fi

  cp -r ./config/picom/ ~/.config/

}

install_bat_and_lsd(){
  # Instalación de Bat
  cd $ruta
  bat_url=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | jq -r '.assets[] | select(.name | endswith("x86_64-unknown-linux-gnu.tar.gz")) | .browser_download_url')
  wget "$bat_url" -O bat.tar.gz &>/dev/null
  tar -xzf bat.tar.gz &>/dev/null 
  sudo mv bat-*/bat /usr/bin/
  rm -rf bat-*
  rm -rf bat.tar.gz 
  
  # Instalación de lsd
  lsd_url=$(curl -s https://api.github.com/repos/lsd-rs/lsd/releases/latest | jq -r '.assets[] | select(.name | endswith("x86_64-unknown-linux-gnu.tar.gz")) | .browser_download_url')
  wget "$lsd_url" -O lsd.tar.gz &>/dev/null
  tar -xzf lsd.tar.gz &>/dev/null
  sudo mv lsd-*/lsd /usr/bin/ 
  rm -rf lsd.tar.gz  
  rm -rf lsd-*
}

install_fonts(){
  cd $ruta
  echo -e "\n${bright_cyan}[+] ${bright_white}Instalando las fuentes necesarias...${end}"
  sudo cp -r fonts/* /usr/local/share/fonts
  mkdir -p ~/.local/share/fonts
  sudo cp -r fonts/* ~/.local/share/fonts
  sudo cp -r fonts/* /usr/share/fonts/truetype/
  sudo cp ./config/polybar/fonts/* /usr/share/fonts/truetype
  fc-cache -v &>/dev/null || echo "\n${bright_red}[!] Error al limpiar la cache de fuente${end}"
}

install_nvim(){
  cd $ruta
  echo -e "\n${bright_cyan}[+]${bright_white} Instalando NvChad...${end}"
  sudo apt autoremove neovim -y; sudo apt autoremove nvim -y 
  rm -rf ~/.config/nvim/ 2>/dev/null
  cp -r ./config/nvim/ ~/.config/
  sudo mkdir -p /root/.config/
  sudo cp -r ./config/nvim/ /root/.config/
  
  sudo apt install jq npm nodejs -y &>/dev/null
  ./nvim_upload.sh &>/dev/null || echo -e "\n${bright_red}[!] NvChad no se pudo instalar...${end}"
  ./InstallUserServersNvim.sh &>/dev/null && echo -e "\n${bright_cyan}[+]${bright_white} Mensajes de advertencia instalados correctamente...${end}" || echo -e "\n${bright_red}[!] No se pudieron instalar los mensajes de advertencia...${end}"
  sudo ./InstallUserServersNvim.sh &>/dev/null 
  sudo cp ./nvim_upload.sh /usr/bin/ 
}

install_eww(){
  cd $ruta
  echo -e "\n${bright_cyan}[+]${bright_white} Instalando eww y sus widgets...${end}"
  if [[ "$distro" == "Kali" ]]; then
      # Instalamos eww y sus dependencias
      sudo apt install -y \
          git build-essential pkg-config \
          libgtk-3-dev libpango1.0-dev libglib2.0-dev libcairo2-dev \
          libdbusmenu-glib-dev libdbusmenu-gtk3-dev \
          libgtk-layer-shell-dev \
          libx11-dev libxft-dev libxrandr-dev libxtst-dev &>/dev/null

      # Si hay un directorio eww lo borramos entero
      [[ -d "eww" ]] && rm -rf "eww"

      git clone https://github.com/elkowar/eww.git &>/dev/null
      cd eww
      
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y &>/dev/null
      source $HOME/.cargo/env
      cargo clean &>/dev/null
      cargo build --release &>/dev/null

      if [[ $? -eq 0 ]]; then
          sudo cp target/release/eww /usr/bin/
          mkdir -p ~/.config/eww
          cd ..
          [[ -d "eww" ]] && rm -rf eww
          # Traemos la configuración de eww
          cp -r ./config/eww/ ~/.config/
      else
          echo -e "\n${bright_red}[!] No se pudo instalar eww...${end}"
          cd ..
      fi
  fi
}

install_tmux(){
  echo -e "\n${bright_cyan}[+]${bright_white} Instalando Tmux...${end}"
  # Instalamos oh-my-tmux para ambos usuarios
  cd /home/$usuario
  git clone --single-branch https://github.com/gpakosz/.tmux.git &>/dev/null
  ln -s -f .tmux/.tmux.conf &>/dev/null
  cp .tmux/.tmux.conf.local . 

  # oh-my-tmux para root
  sudo git clone --single-branch https://github.com/gpakosz/.tmux.git /root/.tmux &>/dev/null
  sudo ln -s -f /root/.tmux/.tmux.conf /root/.tmux.conf &>/dev/null
  sudo cp /root/.tmux/.tmux.conf.local /root/. 
}

install_rofi(){
  echo -e "\n${bright_cyan}[+]${bright_white} Instalando rofi...${end}"
  sudo apt install -y rofi &>/dev/null
  cp -r ./config/rofi/ ~/.config/
  sudo rm -rf /usr/share/rofi/themes/* 2>/dev/null && sudo cp -r ./config/rofi/themes/* /usr/share/rofi/themes/ 
  /usr/bin/clear

  if which notify-send &>/dev/null; then
    notify-send "Entorno BSPWM instalado correctamente!!"
    notify-send "Elige tu tema de rofi para finalizar."
  fi

  echo -e "\n${bright_cyan}[+]${bright_white} Elige tu tema para rofi, una vez lo tengas elegido presiona Ctrl + A.${end}"
  /usr/bin/rofi-theme-selector &>/dev/null
  echo -e "\n${bright_cyan}[+]${bright_white} Espera 10 segundos por favor...${end}"
  sleep 10
  kill -9 -1 
}

install_obsidian(){
  echo -e "\n${bright_cyan}[+]${bright_white} Instalando obsidian...${end}"
  obsidian_url=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | jq -r '.assets[] | select(.name | endswith(".AppImage")) | .browser_download_url' | grep -vi 'arm' )
  wget "$obsidian_url" -O Obsidian.AppImage &>/dev/null
  chmod +x Obsidian.AppImage 
  mv Obsidian.AppImage obsidian 
  sudo mv obsidian /usr/bin/
}

main(){
  cd $ruta
  source ./Colors
  [[ -z $distro ]] && exit 1
  [[ ! -d "$HOME/.config/" ]] && mkdir -p ~/.config/
  update_system
  install_fonts
  install_nvim
  install_bspwm
  install_sxhkd
  install_kitty 
  install_zsh
  install_fzf
  install_bat_and_lsd
  install_p10k
  install_picom
  install_obsidian
  install_tmux 
  [[ ! "$distro" == 'Parrot' ]] && install_eww
  install_polybar
  sudo cp ./Colors /usr/bin/
  install_rofi
}

if [[ "$EUID" -ne 0 ]]; then 
  main
fi
