update() {
if [[ -f /etc/arch-release ]]; then
  alias update="sudo pacman -Syu"
elif [[ -f /etc/debian_version ]]; then
  alias update="sudo apt update && sudo apt upgrade && pipx upgrade-all"
fi
}

fcd() {
  local file
  file=$(fzf)
  [ -n "$file" ] && cd "$(dirname "$file")"
}
