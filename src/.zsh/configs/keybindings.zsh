# Edit command line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey "^O" edit-command-line

# Expand multiple dots (e.g. ... -> ../.. , .... -> ../../..)
# https://qiita.com/momo-lab/items/523fc83fbfa39fa5fd60
function replace_multiple_dots() {
  local dots=$LBUFFER[-2,-1]
  if [[ $dots == ".." ]]; then
    LBUFFER=$LBUFFER[1,-3]'../.'
  fi
  zle self-insert
}
zle -N replace_multiple_dots
bindkey "." replace_multiple_dots

# https://www.m3tech.blog/entry/dotfiles-bonsai
replace_multiple_dots_exclude_go() {
    if [[ "$LBUFFER" =~ '^go ' ]]; then
        zle self-insert
    else
        zle .replace_multiple_dots
    fi
}
zle -N .replace_multiple_dots replace_multiple_dots
zle -N replace_multiple_dots replace_multiple_dots_exclude_go

