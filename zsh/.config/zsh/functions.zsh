# update() {
# if [[ -f /etc/arch-release ]]; then
#   alias update="sudo pacman -Syu"
# elif [[ -f /etc/debian_version ]]; then
#   alias update="sudo apt update && sudo apt upgrade && pipx upgrade-all"
# fi
# }

fcd() {
  local file
  file=$(fzf)
  [ -n "$file" ] && cd "$(dirname "$file")"
}

# usage:
# monset <br_dp1> <ct_dp1> <br_dp2> <ct_dp2>

bright() {
  local br1="$1"
  local ct1="$2"
  local br2="$3"
  local ct2="$4"

  if [[ $# -ne 4 ]]; then
    echo "Gebruik: monset <brightness_dp1> <contrast_dp1> <brightness_dp2> <contrast_dp2>"
    echo "Voorbeeld: monset 70 60 50 55"
    return 1
  fi

  # DP-2 (display 1)
  ddcutil setvcp 10 "$br1" --display 1 --noverify
  ddcutil setvcp 12 "$ct1" --display 1 --noverify

  # DP-3 (display 2)
  ddcutil setvcp 10 "$br2" --display 2 --noverify
  ddcutil setvcp 12 "$ct2" --display 2 --noverify
}
