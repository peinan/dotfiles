#!/bin/zsh
#
# FZF settings
#

if type fzf &>/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS='
        --height ~50%
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
        --bind "ctrl-x:become(fzfx {+})"
    '

    export FZF_COMPLETION_OPTS='--height ~10%'

    source <(fzf --zsh)

    # Use atuin for history search instead of fzf
    bindkey '^R' atuin-search

    # Enhanced fzf-file-widget with timestamps and sort actions
    if type rg > /dev/null 2>&1; then
        export FZF_CTRL_T_COMMAND='fzf-file-list'
    fi
    if type bat > /dev/null 2>&1; then
        export FZF_CTRL_T_OPTS='
            --delimiter "\t"
            --with-nth 1,2,3
            --preview "bat --style=numbers --color=always --line-range :100 {3}"
            --header "CTRL-D: Sort by date | CTRL-S: Sort by size | CTRL-I: Sort by name"
            --bind "ctrl-s:reload(fzf-file-list | sort -t\"\t\" -k2 -rh)"
            --bind "ctrl-d:reload(fzf-file-list | sort -t\"\t\" -k1 -r)"
            --bind "ctrl-i:reload(fzf-file-list | sort -t\"\t\" -k3)"
            --bind "enter:become(printf \"%s\\n\" {+3})"
        '
    fi

    bindkey '^T' fzf-file-widget
    bindkey '\ec' fzf-cd-widget
fi

