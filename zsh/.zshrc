# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi
export PATH="$PATH:/home/mrtn/.local/bin"
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

export EDITOR=nvim
export VISUAL=nvim

source ~/.config/zsh/ytloader.zsh
source ~/.config/zsh/alias.zsh
source ~/.config/zsh/functions.zsh
source ~/.config/zsh/git.sh

# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
source /usr/share/cachyos-zsh-config/cachyos-config.zsh

cl() {
  clear
  echo "(y)=Yazi (t)=Tmux (v)=nVim"
  fastfetch --config ~/.config/fastfetch/config.jsonc
}

alias nightlight="redshift"

mkcd() {
  mkdir -p "$1" && cd "$1"
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}

function sleep() {
  systemctl suspend
}

function sshhaat(){
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
ssh-add -l
git pull
}

alias ssha="ssh-add ~/.ssh/id_ed25519"

alias rebar="pkill waybar && waybar & disown"

echo "(y)=Yazi (t)=Tmux (v)=nVim"
fastfetch --config ~/.config/fastfetch/config.jsonc

if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
  tmux has-session -t home 2>/dev/null ||
    tmux new-session -d -s home -c "$HOME"

  tmux has-session -t btop 2>/dev/null ||
    tmux new-session -d -s btop btop

  tmux has-session -t spotify 2>/dev/null || {
    tmux new-session -d -s spotify
    tmux send-keys -t spotify "spotatui"
  }

  tmux has-session -t notes 2>/dev/null ||
    tmux new-session -d -s notes -c "$HOME/Documents/Obsidian" nvim .

  tmux has-session -t dotfiles 2>/dev/null ||
    tmux new-session -d -s dotfiles -c "$HOME/linux-dotfiles"

  tmux attach-session -t home
fi
