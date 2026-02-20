#!/usr/bin/env bash

NC="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
PURPLE="\033[38;5;105m"
GRAY="\033[38;5;240m"

DIVIDER="${GRAY}∣${NC}"

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // 1')

format_tokens() {
  local n=$1
  if [ "$n" -ge 1000000 ]; then
    printf "%.0fM" "$(echo "$n / 1000000" | bc -l)"
  elif [ "$n" -ge 1000 ]; then
    printf "%.0fk" "$(echo "$n / 1000" | bc -l)"
  else
    printf "%d" "$n"
  fi
}

pct=${used_pct%.*}
used_tokens=$(( ctx_size * pct / 100 ))
used_fmt=$(format_tokens "$used_tokens")
total_fmt=$(format_tokens "$ctx_size")

bar_width=10
bar_filled=""
bar_empty=""

if [ "$pct" -ge 80 ]; then
  color="$RED"
elif [ "$pct" -ge 50 ]; then
  color="$YELLOW"
else
  color="$GREEN"
fi

filled=$(( pct * bar_width / 100 ))
empty=$(( bar_width - filled ))
for ((i=0; i<filled; i++)); do bar_filled="${bar_filled}█"; done
for ((i=0; i<empty; i++));  do bar_empty="${bar_empty}░"; done

printf "${DIM}%s${NC} ${DIVIDER} ${DIM}Usage${NC} ${color}%s${GRAY}%s${NC} ${DIM}%s/%s${NC} ${DIM}[%d%%]${NC}" \
  "$model" "$bar_filled" "$bar_empty" "$used_fmt" "$total_fmt" "$pct"
