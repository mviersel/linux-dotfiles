# Automatische installer maken (install.sh)

Starting a new system?
- Arch 
Look for [packages](https://archlinux.org/packages/?sort=&q=rofi&maintainer=&flagged=)
- Ubuntu
- Fedora



Op een nieuwe machine:
```
git clone git@github.com:mviersel/linux-dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

Dit is wat je setup reproduceerbaar maakt:

```
#!/usr/bin/env bash

set -e

DOTFILES="$HOME/.dotfiles"

# Bash
ln -sf "$DOTFILES/bash/bashrc" "$HOME/.bashrc"

# Git
ln -sf "$DOTFILES/git/gitconfig" "$HOME/.gitconfig"

# Neovim
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES/nvim" "$HOME/.config/nvim"

echo "Dotfiles installed!"
```

Uitvoerbaar maken:
```
chmod +x install.sh
```
