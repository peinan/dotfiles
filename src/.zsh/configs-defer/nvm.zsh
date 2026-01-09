#!/bin/zsh
#
# Use lazy load because nvm.sh is extremely slow
#

nvm() {
    unset -f nvm node npm npx 
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm "$@"
}

node() { nvm > /dev/null; node "$@" }
npm() { nvm > /dev/null; npm "$@" }
npx() { nvm > /dev/null; npx "$@" }

