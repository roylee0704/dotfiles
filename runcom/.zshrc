# If not running interactively, don't do anything

[[ -o interactive ]] || return

# Resolve DOTFILES_DIR

if [ -d "$HOME/.dotfiles" ]; then
  DOTFILES_DIR="$HOME/.dotfiles"
elif [ -d "$HOME/dotfiles" ]; then
  DOTFILES_DIR="$HOME/dotfiles"
else
  echo "Unable to find dotfiles, exiting."
  return
fi

# Make utilities available

PATH="$DOTFILES_DIR/bin:$PATH"

# Source the dotfiles (order matters)

[ -f "$DOTFILES_DIR/system/.exports" ] && . "$DOTFILES_DIR/system/.exports"

for DOTFILE in "$DOTFILES_DIR"/system/.{function,function_*,n,path,env,alias,fzf,grep,prompt,completion,fix,pnpm,zoxide}; do
  [ -f "$DOTFILE" ] && . "$DOTFILE"
done

if is-macos; then
  for DOTFILE in "$DOTFILES_DIR"/system/.{env,alias,function}.macos; do
    [ -f "$DOTFILE" ] && . "$DOTFILE"
  done
fi

# Set LSCOLORS

eval "$(dircolors -b "$DOTFILES_DIR"/system/.dir_colors)"

# Wrap up

unset DOTFILE

export DOTFILES_DIR
