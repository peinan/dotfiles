# -------------------------------------
# Variables
# -------------------------------------

export PAGER=/usr/bin/less
export MANPAGER=/usr/bin/less
export LESS='-RMi'
export EDITOR=nvim sheldon edit
export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=10000000
export SAVEHIST=10000000
export WORDCHARS='.-_'

# Delete words with CTRL+W
# https://unix.stackexchange.com/a/392199
autoload -U select-word-style && select-word-style bash
set -o emacs


# -------------------------------------
# Sheldon
# -------------------------------------

eval "$(sheldon source)"


# -------------------------------------
# Aliases
# -------------------------------------

source "${HOME}/.alias"


# -------------------------------------
# Completions
# -------------------------------------

# Homebrew
if type brew &>/dev/null; then
    eval $(/opt/homebrew/bin/brew shellenv)
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
fi

# iTerm
if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
    test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
fi

# Docker
fpath=(~/.zsh/completion $fpath)
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

autoload -Uz compinit && compinit

