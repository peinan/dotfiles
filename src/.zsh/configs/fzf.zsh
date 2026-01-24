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
    # Sort mode cycle: date -> size -> name -> date
    if type rg > /dev/null 2>&1; then
        export FZF_CTRL_T_COMMAND='echo Date > /tmp/fzf-sort-mode; fzf-file-list Date'
    fi
    if type bat > /dev/null 2>&1; then
        export FZF_CTRL_T_OPTS='
            --delimiter "│"
            --with-nth 1,2,3
            --preview "bat --style=numbers --color=always --line-range :100 \$(echo {3} | sed \"s/^ //\")"
            --preview-window "right,60%"
            --preview-window "<100(down,40%)"
            --header "[Sort: Date] Press CTRL-S to cycle sort"
            --bind "ctrl-s:transform:
                mode=\$(cat /tmp/fzf-sort-mode 2>/dev/null || echo Date);
                case \$mode in
                    Date) next=Size ;;
                    Size) next=Name ;;
                    *) next=Date ;;
                esac;
                echo \$next > /tmp/fzf-sort-mode;
                echo \"reload(fzf-file-list \$next)+change-header([Sort: \$next] Press CTRL-S to cycle sort)\""
            --bind "enter:become(printf \"%s\\n\" {+3} | sed \"s/^ //\")"
        '
    fi

    bindkey '^T' fzf-file-widget
    bindkey '\ec' fzf-cd-widget
fi

