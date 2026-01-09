# -------------------------------------
# Variables
# -------------------------------------

# Pager
export PAGER=/usr/bin/less
export MANPAGER=/usr/bin/less
export LESS='-RMi'

# History
export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=10000000
export SAVEHIST=10000000

# Delete words with CTRL+W
# https://unix.stackexchange.com/a/392199
autoload -U select-word-style
select-word-style bash
export WORDCHARS='.-_'

set -o emacs

# Use nvim for the default editor
export EDITOR=nvim sheldon edit

# -------------------------------------
# Shell Initialization
# -------------------------------------

# zsh-autosuggestions
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# sheldon
eval "$(sheldon source)"

# alias
source "${HOME}/.alias"

# iTerm
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


# -------------------------------------
# zsh completions (Homebrew)
# -------------------------------------

fpath=(~/.zsh/completion $fpath)
#### use sheldon
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
fi

# completions for docker
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

autoload -Uz compinit && compinit

# -------------------------------------
# walk
# -------------------------------------

export WALK_EDITOR=nvim

# -------------------------------------
# Windsurf
# -------------------------------------

export PATH="$HOME/.codeium/windsurf/bin:$PATH"

# -------------------------------------
# LM Studio
# -------------------------------------

export PATH="$PATH:$HOME/.cache/lm-studio/bin"

# -------------------------------------
# Antigravity
# -------------------------------------

export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# -------------------------------------
# aicommit2
# -------------------------------------

export AICOMMIT_CONFIG_PATH="$HOME/.config/aicommit2/config.ini"

# -------------------------------------
# Coreutils
# -------------------------------------

PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"

