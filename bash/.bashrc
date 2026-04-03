export PATH="$PATH:/home/martijn/.local/bin"

source ~/.config/bash/ytloader.bsh
source ~/.config/bash/alias.bsh
source ~/.config/bash/functions.bsh
source ~/.config/bash/wsl.bsh
source ~/.config/bash/spotdl.bsh.local

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

apdate() {
  sudo apt update && sudo apt upgrade -y
}

cl() {
  clear
  fastfetch
}

fastfetch
