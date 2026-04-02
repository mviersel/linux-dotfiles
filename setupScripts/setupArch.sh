#!/bin/bash

# ==============================
# CONFIGURATIE
# ==============================

# Voeg hier je pacman packages toe
PACMAN_PACKAGES=(
  yay
  neovim
  git
)

# Voeg hier je yay (AUR) packages toe
YAY_PACKAGES=(
  zen-browser-bin
  visual-studio-code-bin
)

# ==============================
# SCRIPT
# ==============================

echo "Systeem updaten..."
sudo pacman -Syu --noconfirm

echo "Pacman packages installeren..."
if [ ${#PACMAN_PACKAGES[@]} -ne 0 ]; then
  sudo pacman -S --noconfirm --needed "${PACMAN_PACKAGES[@]}"
else
  echo "Geen pacman packages opgegeven."
fi

# Check of yay geïnstalleerd is
if ! command -v yay &>/dev/null; then
  echo "yay niet gevonden. Installeren..."

  tmp_dir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"
  cd "$tmp_dir/yay" || exit
  makepkg -si --noconfirm
  cd - || exit
fi

echo "Yay (AUR) packages installeren..."
if [ ${#YAY_PACKAGES[@]} -ne 0 ]; then
  yay -S --noconfirm --needed "${YAY_PACKAGES[@]}"
else
  echo "Geen yay packages opgegeven."
fi

echo "Klaar!"
