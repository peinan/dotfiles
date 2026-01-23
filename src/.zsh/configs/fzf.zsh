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
        export FZF_CTRL_T_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
    fi
    if type bat > /dev/null 2>&1; then
        export FZF_CTRL_T_OPTS='
            --preview "
                echo -e \"\033[1;34mFile:\033[0m {}\"
                echo -e \"\033[1;34mModified:\033[0m \$(ls -lh {} 2>/dev/null | awk \"{print \\\$6, \\\$7, \\\$8}\")\"
                echo -e \"\033[1;34mSize:\033[0m \$(ls -lh {} 2>/dev/null | awk \"{print \\\$5}\")\"
                echo \"\"
                bat --style=numbers --color=always --style=header,grid --line-range :100 {}
            "
            --header "CTRL-S: Sort by size | CTRL-D: Sort by date | CTRL-N: Sort by name"
            --bind "ctrl-s:reload(rg --files --hidden --follow --glob \"!.git/*\" | xargs ls -lhS 2>/dev/null | awk \"{print \\\$NF}\")"
            --bind "ctrl-d:reload(rg --files --hidden --follow --glob \"!.git/*\" | xargs ls -lht 2>/dev/null | awk \"{print \\\$NF}\")"
            --bind "ctrl-n:reload(rg --files --hidden --follow --glob \"!.git/*\" | sort)"
        '
    fi

    bindkey '^T' fzf-file-widget
    bindkey '\ec' fzf-cd-widget
fi

