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

# starship
eval "$(starship init zsh)"

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
# fzf
# -------------------------------------

export FZF_DEFAULT_OPTS='
    --height ~100%
    --layout reverse
    --info "inline-right: "
    --info-command="echo -e \"$FZF_POS/$FZF_INFO\""
    --prompt ""
    --input-border=rounded
    --pointer " "
    --multi
    --marker " ▌"
    --scrollbar "▌"
    --color="bg+:-1,gutter:#2d2d2d,pointer:#99cc99,prompt:#81A1C1,info:#686868,spinner:#f2777a" --gutter " "
'
source <(fzf --zsh)
# TODO: enhance the UI of fzf-file-widget and fzf-cd-widget
if type rg > /dev/null 2>&1; then
  export FZF_CTRL_T_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
fi
if type bat > /dev/null 2>&1; then
  export FZF_CTRL_T_OPTS='--preview "bat --style=numbers --color=always --style=header,grid --line-range :100 {}"'
fi
bindkey '^T' fzf-file-widget
bindkey '\ec' fzf-cd-widget

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
export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS --no-sort --height 10% --preview-window=down,50%,wrap --preview 'eza --color=always {2}'"
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
if [ -f '$HOME/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '$HOME/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '$HOME/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '$HOME/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

# -------------------------------------
# Rust
# -------------------------------------

. "$HOME/.cargo/env"

# -------------------------------------
# Windsurf
# -------------------------------------

export PATH="$HOME/.codeium/windsurf/bin:$PATH"

# -------------------------------------
# LM Studio
# -------------------------------------

export PATH="$PATH:$HOME/.cache/lm-studio/bin"

# -------------------------------------
# Kiro
# -------------------------------------

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# -------------------------------------
# NVM (Node Version Manager)
# -------------------------------------

# Use lazy load because nvm.sh is extremely slow
nvm() {
  unset -f nvm node npm npx 
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}

node() { nvm > /dev/null; node "$@" }
npm() { nvm > /dev/null; npm "$@" }
npx() { nvm > /dev/null; npx "$@" }

# -------------------------------------
# Antigravity
# -------------------------------------

export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# -------------------------------------
# aicommit2
# -------------------------------------

export AICOMMIT_CONFIG_PATH="$HOME/.config/aicommit2/config.ini"

# -------------------------------------
# atuin
# -------------------------------------

eval "$(atuin init zsh --disable-up-arrow)"

# -------------------------------------
# Starship
# -------------------------------------

export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml
export STARSHIP_CACHE=$HOME/.cache/starship

# -------------------------------------
# Coreutils
# -------------------------------------

PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"

