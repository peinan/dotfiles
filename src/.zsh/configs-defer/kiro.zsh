#!/bin/zsh
#
# Kiro
#

if type kiro &>/dev/null 2>&1; then
    [[ "$TERM_PROGRAM" == "kiro" ]] && source "$(kiro --locate-shell-integration-path zsh)"
fi

