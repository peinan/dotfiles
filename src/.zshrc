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

# Clear SSH related variables in specific condition
if [[ -n "$TMUX" && -n "$SSH_CONNECTION" && -z "$SSH_TTY" ]]; then
    unset SSH_CONNECTION SSH_CLIENT SSH_TTY
fi

# -------------------------------------
# Homebrew
# -------------------------------------

eval $(/opt/homebrew/bin/brew shellenv)

# -------------------------------------
# Sheldon
# -------------------------------------

# Prevent zsh-autosuggestions from wrapping zeno widgets (Issue #21)
# Must be set before sheldon loads zsh-autosuggestions
ZSH_AUTOSUGGEST_IGNORE_WIDGETS=(
    orig-\*
    beep
    run-help
    set-local-history
    which-command
    yank
    yank-pop
    zle-\*
    zeno-\*
)

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
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
fi

# iTerm
if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
    test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
fi

# Docker
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"

fpath=(~/.zsh/completion $fpath)
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

autoload -Uz compinit && compinit

# fzf-tab
source ~/ghq/github.com/Aloxaf/fzf-tab/fzf-tab.plugin.zsh
zstyle ':fzf-tab:*' fzf-flags --pointer="" --color="bg+:-1,gutter:#2d2d2d,pointer:#99cc99,prompt:#81A1C1,info:#686868,spinner:#f2777a" --gutter=" " --marker="▌" --scrollbar="▌" --prompt="" --info="hidden"
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:cd:*' popup-pad 30 0

# zeno.zsh
export ZENO_HOME=$XDG_CONFIG_HOME/zeno
source ~/ghq/github.com/yuki-yano/zeno.zsh/zeno.zsh
if [[ -n $ZENO_LOADED ]]; then
    bindkey " " zeno-auto-snippet
    bindkey '^m' zeno-auto-snippet-and-accept-line
    bindkey '^x ' zeno-insert-space
    bindkey '^x^m' accept-line
fi

# MySQL
export PATH="/opt/homebrew/opt/mysql-client@8.0/bin:$PATH"

# -------------------------------------
# herdr pane title
# -------------------------------------

# Set the herdr pane border title to "<dir>: <command>".
# idle (at prompt) -> shell name; while a command runs -> that command.
if [[ -n "$HERDR_PANE_ID" ]] && (( $+commands[herdr] )); then
    autoload -Uz add-zsh-hook

    _herdr_pane_title() {
        local cmd="$1"
        local dir; [[ "$PWD" == "$HOME" ]] && dir="~" || dir="${PWD:t}"
        herdr pane rename "$HERDR_PANE_ID" "${dir} ${cmd}" &>/dev/null
    }

    _herdr_pane_title_idle() { _herdr_pane_title "${SHELL:t}" }   # prompt -> "zsh"
    _herdr_pane_title_exec() { _herdr_pane_title "${1%% *}" }     # before run -> command

    add-zsh-hook precmd  _herdr_pane_title_idle
    add-zsh-hook preexec _herdr_pane_title_exec
    _herdr_pane_title_idle
fi
