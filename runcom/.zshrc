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
# Skip bash-only files: .env (shopt), .prompt (PROMPT_COMMAND), .completion (complete)

[ -f "$DOTFILES_DIR/system/.exports" ] && . "$DOTFILES_DIR/system/.exports"

for DOTFILE in "$DOTFILES_DIR"/system/.{function,function_*,n,path,alias,fzf,grep,fix,pnpm,zoxide}; do
  [ -f "$DOTFILE" ] && . "$DOTFILE"
done

if is-macos; then
  for DOTFILE in "$DOTFILES_DIR"/system/.{alias,function}.macos; do
    [ -f "$DOTFILE" ] && . "$DOTFILE"
  done
fi

# zsh equivalents of .env settings

export EDITOR="nano"
export VISUAL="nano"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_RUNTIME_DIR="$HOME/.local/runtime"
export HISTSIZE=32768
export SAVEHIST=4096
export HISTFILE="$HOME/.zsh_history"
export CLICOLOR=1
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LESS_TERMCAP_md="${yellow}"
export MANPAGER='less -X'

setopt nocaseglob
setopt globstarshort
setopt appendhistory
setopt correct

# zsh prompt

autoload -Uz add-zsh-hook

_zsh_prompt() {
  local exit_code=$?
  local p_exit=""
  if [[ $exit_code != 0 ]]; then
    p_exit="%F{red}✘ %f"
  fi
  local p_user="%F{green}%n%f"
  local p_host="%F{cyan}%m%f"
  local p_pwd="%F{yellow}%~%f"
  local p_git=""
  local branch=$(git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
  if [[ -n "$branch" ]]; then
    p_git=" %F{green}${branch}%f"
  fi
  PROMPT="${p_exit}${p_user}%F{white}@%f${p_host} ${p_pwd}${p_git} %F{yellow}❯%f "
}

add-zsh-hook precmd _zsh_prompt

# zsh completion

autoload -Uz compinit && compinit

# Set LSCOLORS

if is-executable dircolors; then
  eval "$(dircolors -b "$DOTFILES_DIR"/system/.dir_colors)"
fi

# Wrap up

unset DOTFILE

export DOTFILES_DIR
