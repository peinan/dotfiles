# -------------------------------------
# Initializing
# -------------------------------------


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


# -------------------------------------
# evals
# -------------------------------------

# zsh-autosuggestions
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# starship
eval "$(starship init zsh)"

# sheldon
eval "$(sheldon source)"

# alias
source "${HOME}/.alias"

# iTerm
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# -------------------------------------
# Functions
# -------------------------------------

## change iTerm tab title
#---------------------------
function chpwd() { ls; }

## make directory and cd
#-----------------------
function mkcd() { mkdir -p "$@" && cd "$@"; }

## change title
#--------------
function title() { echo -ne "\e]1;$1\a"; }

## get timestamp
#--------------
function ts {
  date +'%Y%m%dt%H%M%S'
}

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
# fzf
# -------------------------------------

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if type rg > /dev/null 2>&1; then
  export FZF_CTRL_T_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
fi
if type bat > /dev/null 2>&1; then
  export FZF_CTRL_T_OPTS='--preview "bat --style=numbers --color=always --style=header,grid --line-range :100 {}"'
fi

# -------------------------------------
# walk
# -------------------------------------

function lk {
  cd "$(walk --icons "$@")"
}
export WALK_EDITOR=nvim

# -------------------------------------
# zoxide
# -------------------------------------

eval "$(zoxide init zsh)"
zle -N __zoxide_zi
bindkey '^z' __zoxide_zi

# -------------------------------------
# bun
# -------------------------------------

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# -------------------------------------
# 1Password CLI
# -------------------------------------

eval "$(op completion zsh)"; compdef _op op
export OP_BIOMETRIC_UNLOCK_ENABLED=true

# -------------------------------------
# Google SDK
# -------------------------------------

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/Downloads/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/Downloads/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc"; fi

# ---
. "$HOME/.cargo/env"

# Added by Windsurf
export PATH="$HOME/.codeium/windsurf/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.cache/lm-studio/bin"
# End of LM Studio CLI section


[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
