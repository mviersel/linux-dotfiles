# Arch/CachyOs setup

## Programs

## Fonts

### Emojis
[github](https://github.com/androlabs/emoji-archlinux)
```
$ sudo pacman -S noto-fonts-emoji
```


## Setup

### SSH nightmare
To make sure you don't have to enter the password each time we use the ssh-agent:
```
systemctl --user enable --now ssh-agent.socket
```
After that we point the shell to the path of the ssh-agent-socket:
```
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
```

In the `~/.ssh/config` we put:
```
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
  AddKeysToAgent yes
```
To say that what ssh code is supposed to work with the project.

In the project folder we add the ssh-key:
```
ssh-add ~/.ssh/id_ed25519
```


