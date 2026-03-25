#!/usr/bin/env bash
set -euo pipefail

DOTFILES_BASH_DIR="${1:-$HOME/linux-dotfiles/bash/}"

if [[ ! -d "$DOTFILES_BASH_DIR" ]]; then
  echo "Map bestaat niet: $DOTFILES_BASH_DIR" >&2
  exit 1
fi

echo "Zoeken naar bestanden met CRLF in: $DOTFILES_BASH_DIR"
echo

found=0

while IFS= read -r -d '' file; do
  if grep -q $'\r' "$file"; then
    echo "Fixing: $file"
    sed -i 's/\r$//' "$file"
    found=1
  fi
done < <(find "$DOTFILES_BASH_DIR" -type f -print0)

echo
if [[ $found -eq 0 ]]; then
  echo "Geen bestanden met \\r gevonden."
else
  echo "Klaar. Alle gevonden \\r-tekens zijn verwijderd."
fi
