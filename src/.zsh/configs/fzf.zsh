#!/bin/zsh
#
# FZF settings
#

if type fzf &>/dev/null 2>&1; then
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

    # Use atuin for history search instead of fzf
    bindkey '^R' atuin-search

    # TODO: enhance the UI of fzf-file-widget and fzf-cd-widget
    if type rg > /dev/null 2>&1; then
        export FZF_CTRL_T_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
    fi
    if type bat > /dev/null 2>&1; then
        export FZF_CTRL_T_OPTS='
            --preview "bat --style=numbers --color=always --style=header,grid --line-range :100 {}"
        '
    fi

    bindkey '^T' fzf-file-widget
    bindkey '\ec' fzf-cd-widget
fi

