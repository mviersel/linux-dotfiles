#!/usr/bin/env bash
set -euo pipefail

# Browser
xdg-settings set default-web-browser helium.desktop

# xdg-mime default firefox.desktop text/html
# xdg-mime default firefox.desktop x-scheme-handler/http
# xdg-mime default firefox.desktop x-scheme-handler/https

# Mail
# xdg-mime default thunderbird.desktop x-scheme-handler/mailto

# PDF
# xdg-mime default org.pwmt.zathura.desktop application/pdf

# Images
# xdg-mime default imv.desktop image/png
# xdg-mime default imv.desktop image/jpeg
# xdg-mime default imv.desktop image/webp
