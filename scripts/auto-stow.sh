#!/usr/bin/env bash

PACKAGES=(
    backgrounds
    bin
    fastfetch
    ghostty
    git
    hypridle
    hyprland
    hyprland
    hyprpaper
    hypersunset
    kitty
    mako
    nvim
    quickshell
    starship
    tmux
    vicinae
    yazi
    zsh
)

log "Stow packages linken"
for pkg in "${PACKAGES[@]}"; do
    if [[ -d "$pkg" ]]; then
        echo "-> $pkg"
        stow --restow --target="$HOME" "$pkg"
    else
        echo "-> overslaan: $pkg bestaat niet"
    fi
done
