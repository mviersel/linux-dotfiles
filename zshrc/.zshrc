# usage with nvim version and location in one
alias nvim-lazy="NVIM_APPNAME=LazyVim nvim"

# with nvimS in terminal
function nvims() {
  # change list item for more options
  items=("default", "nvim-lazy" )

  config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)
  if [[ -z $config ]]; then
    echo "Nothing selected"
    return 0
  elif [[ $config == "default" ]]; then
    config=""
  fi
  NVIM_APPNAME=$config nvim $@
}

bindkey -s ^a "nvims\n"
