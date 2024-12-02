### **¿Cómo usar?**

```
cd AutoBSPWM
chmod +x desktop.sh
./desktop.sh
```

------------------------------------------------------------------------

### **Atajos de teclado**
- **`Windows + Enter -> /opt/kitty/bin/kitty`**  
- **`Windows + Shift + O -> /usr/bin/obsidian`**  
- **`Windows + Shift + X -> /usr/bin/i3lock-fancy`**  
- **`Windows + D -> ~/.config/rofi/launchers/type-6/launcher.sh`**  
- **`Windows + Escape -> pkill -USR1 -x sxhkd`**  
- **`Windows + Shift + F -> /usr/bin/firefox`**  
- **`Windows + Shift + {Q,R} -> bspc {quit,wm -r}`**  
- **`Windows + {Q,Shift + Q} -> bspc node -{c,k}`**  
- **`Windows + M -> bspc desktop -l next`**  
- **`Windows + Y -> bspc node newest.marked.local -n newest.!automatic.local`**  
- **`Windows + G -> bspc node -s biggest.window`**  
- **`Windows + {T,Shift + T,S,F} -> bspc node -t {tiled,pseudo_tiled,floating,fullscreen}`**  
- **`Windows + Ctrl + {M,X,Y,Z} -> bspc node -g {marked,locked,sticky,private}`**  
- **`Windows + {Left,Down,Up,Right} -> bspc node -f {west,south,north,east}`**  
- **`Windows + Shift + {Left,Down,Up,Right} -> bspc node -s {west,south,north,east}`**  
- **`Windows + {P,B,Comma,Period} -> bspc node -f @{parent,brother,first,second}`**  
- **`Windows + {C,Shift + C} -> bspc node -f {next,prev}.local.!hidden.window`**  
- **`Windows + Bracket {Left,Right} -> bspc desktop -f {prev,next}.local`**  
- **`Windows + {Grave,Tab} -> bspc {node,desktop} -f last`**  
- **`Windows + {O,I} -> bspc wm -h off; bspc node {older,newer} -f; bspc wm -h on`**  
- **`Windows + {1-9,Shift + 1-9} -> bspc {desktop -f,node -d} ^{1-9}`**  
- **`Windows + Ctrl + Alt + {Left,Down,Up,Right} -> bspc node -p {west,south,north,east}`**  
- **`Windows + Ctrl + {1-9} -> bspc node -o 0.{1-9}`**  
- **`Windows + Ctrl + Alt + Space -> bspc node -p cancel`**  
- **`Windows + Ctrl + Shift + Space -> bspc query -N -d | xargs -I id -n 1 bspc node id -p cancel`**  
- **`Windows + Shift + {Left,Down,Up,Right} -> bspc node -v {-20 0,0 20,0 -20,20 0}`**  
- **`Windows + Alt + {Left,Down,Up,Right} >/home/kali/.config/bspwm/scripts/bspwm_resize {west,south,north,east}`**  
- **`Windows + a -> flameshot gui -p /home/kali/Imágenes/capturas/$(date +"%Y-%m-%d_%H-%M-%S").png`**  

**Esto es una prueba y no debes ejecutar el script :)**
