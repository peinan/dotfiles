#!/bin/zsh
#
# Zoxide settings
#

if type zoxide &>/dev/null 2>&1; then
    # Initialize
    eval "$(zoxide init zsh)"

    # Configure
    export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS
        --no-sort
        --height 10%
        --preview-window=down,50%,wrap
        --preview 'eza --color=always {2}'
    "

    # Bind widgets
    function __zoxide_zi_widget() {
        local result
        result="$(\command zoxide query --interactive)" || {
            zle reset-prompt
            return
        }
        BUFFER="cd ${(q)result}"
        zle reset-prompt
        zle accept-line
    }
    zle -N __zoxide_zi_widget
    bindkey '^z' __zoxide_zi_widget
fi

