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
  if [[ $# -ne 4 ]]; then
    echo "Gebruik: bright <br1> <ct1> <br2> <ct2>"
    echo "Voorbeeld: bright 70 60 50 55"
    return 1
  fi

  local br1="$1" ct1="$2"
  local br2="$3" ct2="$4"

  # DP-2 → /dev/i2c-6
  ddcutil setvcp 10 "$br1" --bus 6 --noverify
  ddcutil setvcp 12 "$ct1" --bus 6 --noverify

  # DP-3 → /dev/i2c-7
  if [[ -r /sys/class/drm/card1-DP-3/status ]] &&
     [[ "$(< /sys/class/drm/card1-DP-3/status)" == "connected" ]]; then

    ddcutil setvcp 10 "$br2" --bus 7 --noverify
    ddcutil setvcp 12 "$ct2" --bus 7 --noverify
  fi

  # HDMI-A-1 → /dev/i2c-4 (alleen indien aangesloten)
  if [[ -r /sys/class/drm/card1-HDMI-A-1/status ]] &&
     [[ "$(< /sys/class/drm/card1-HDMI-A-1/status)" == "connected" ]]; then

    ddcutil setvcp 10 "$br1" --bus 4 --noverify
    ddcutil setvcp 12 "$ct1" --bus 4 --noverify
  fi
}

movr() {
    local root_dir
    root_dir="$(pwd -P)"

    find "$root_dir" -mindepth 2 -type f -print0 |
    while IFS= read -r -d '' source_file; do
        local filename destination count

        filename="$(basename "$source_file")"
        destination="$root_dir/$filename"

        if [[ -e "$destination" ]]; then
            count=1
            while [[ -e "$root_dir/${count}_$filename" ]]; do
                ((count++))
            done
            destination="$root_dir/${count}_$filename"
        fi

        mv -- "$source_file" "$destination"
        echo "Copied: $filename"
    done

    echo "Done."
}

hyper() {
    v ~/.config/hypr/hyprland.lua
}
