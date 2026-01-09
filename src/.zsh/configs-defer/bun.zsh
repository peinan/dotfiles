#!/bin/zsh
#
# bun settings
#

# Completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Configure paths
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

