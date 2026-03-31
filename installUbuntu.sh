#!/usr/bin/env bash

set -euo pipefail

# Pad naar je dotfiles repo (pas aan als je iets anders gebruikt)
DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

log() {
  printf '\n[%s] %s\n' "$(date +'%Y-%m-%d %H:%M:%S')" "$*"
}

install_apt_list() {
  local file="$1"
  local label="$2"

  if [ -f "$file" ]; then
    log "Installeer APT-packages voor: $label (bron: $(basename "$file"))"
    # -r zorgt dat xargs niks doet als het bestand leeg is
    xargs -r -a "$file" sudo apt install -y
  else
    log "Sla over: $label (bestand niet gevonden: $(basename "$file"))"
  fi
}

log "Gebruik DOTFILES map: $DOTFILES"

# --------------------------------------------------
# 1) APT packages (core + gui)
# --------------------------------------------------

log "Update APT package index"
sudo apt update

# Core CLI tools (servers / alle machines)
install_apt_list "$DOTFILES/packages-core.txt" "core CLI tools"

# GUI apps via APT (desktop only)
install_apt_list "$DOTFILES/packages-gui.txt" "GUI apps (APT)"

# (Optioneel: als je later bv. packages-dev.txt wilt toevoegen)
# install_apt_list "$DOTFILES/packages-dev.txt" "development tools"

# --------------------------------------------------
# 2) Flatpak apps (GUI via Flathub)
# --------------------------------------------------

# Ondersteun zowel flatpak.txt (voorkeur) als oudere flatpaks.txt naam
FLATPAK_LIST=""
if [ -f "$DOTFILES/flatpak.txt" ]; then
  FLATPAK_LIST="$DOTFILES/flatpak.txt"
elif [ -f "$DOTFILES/flatpaks.txt" ]; then
  FLATPAK_LIST="$DOTFILES/flatpaks.txt"
fi

if [ -n "${FLATPAK_LIST:-}" ]; then
  log "Flatpak app-lijst gevonden: $(basename "$FLATPAK_LIST")"

  if ! command -v flatpak >/dev/null 2>&1; then
    log "Flatpak niet gevonden, installeren via APT..."
    sudo apt install -y flatpak
  fi

  # Flathub remote toevoegen als die er nog niet is
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

  log "Installeer Flatpak apps vanaf $(basename "$FLATPAK_LIST")"
  xargs -r -a "$FLATPAK_LIST" flatpak install -y flathub
else
  log "Geen flatpak.txt of flatpaks.txt gevonden, sla Flatpak-installatie over."
fi

log "✅ Installatie van packages-core, packages-gui en Flatpak apps voltooid."
# Flatpak apps
if [ -f "$DOTFILES/flatpaks.txt" ]; then
  if ! command -v flatpak &>/dev/null; then
    sudo apt install -y flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  fi

  xargs -a "$DOTFILES/flatpaks.txt" flatpak install -y flathub
fi
if [ -f "$DOTFILES/packages.txt" ]; then
  sudo apt update
  xargs -a "$DOTFILES/packages.txt" sudo apt install -y
fi
