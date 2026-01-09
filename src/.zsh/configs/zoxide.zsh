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
    zle -N __zoxide_zi
    bindkey '^z' __zoxide_zi
fi

