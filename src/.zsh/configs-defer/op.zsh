#!/bin/zsh
#
# 1Password CLI (op)
#

if type op &>/dev/null 2>&1; then
    eval "$(op completion zsh)"
    compdef _op op
    export OP_BIOMETRIC_UNLOCK_ENABLED=true
fi
