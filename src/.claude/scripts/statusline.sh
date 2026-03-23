#!/usr/bin/env bash

NC="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
PURPLE="\033[38;5;105m"
GRAY="\033[38;5;239m"

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

color_for_pct() {
  local p=$1
  if [ "$p" -ge 80 ]; then
    printf "%s" "$RED"
  elif [ "$p" -ge 50 ]; then
    printf "%s" "$YELLOW"
  else
    printf "%s" "$GREEN"
  fi
}

format_time_until() {
  local reset_epoch=$1
  [ -z "$reset_epoch" ] && return

  local now_epoch delta
  now_epoch=$(date +%s)
  delta=$(( reset_epoch - now_epoch ))
  [ "$delta" -le 0 ] && { printf "now"; return; }

  local days hours minutes
  days=$(( delta / 86400 ))
  hours=$(( (delta % 86400) / 3600 ))
  minutes=$(( (delta % 3600) / 60 ))

  if [ "$days" -gt 0 ]; then
    printf "%dd %dh" "$days" "$hours"
  elif [ "$hours" -gt 0 ]; then
    printf "%dh %dm" "$hours" "$minutes"
  else
    printf "%dm" "$minutes"
  fi
}

# --- Context window ---
pct=${used_pct%.*}
used_tokens=$(( ctx_size * pct / 100 ))
used_fmt=$(format_tokens "$used_tokens")
total_fmt=$(format_tokens "$ctx_size")

bar_width=10
bar_filled=""
bar_empty=""

color=$(color_for_pct "$pct")

filled=$(( pct * bar_width / 100 ))
empty=$(( bar_width - filled ))
for ((i=0; i<filled; i++)); do bar_filled="${bar_filled}█"; done
for ((i=0; i<empty; i++));  do bar_empty="${bar_empty}░"; done

# --- Usage limits (from rate_limits field in stdin) ---
usage_section=""
five_h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty | floor' 2>/dev/null)
seven_d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty | floor' 2>/dev/null)
five_h_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty' 2>/dev/null)
seven_d_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty' 2>/dev/null)

if [ -n "$five_h" ] && [ -n "$seven_d" ]; then
  five_h_color=$(color_for_pct "$five_h")
  seven_d_color=$(color_for_pct "$seven_d")
  five_h_time=$(format_time_until "$five_h_reset")
  seven_d_time=$(format_time_until "$seven_d_reset")
  five_h_reset_str=""
  seven_d_reset_str=""
  [ -n "$five_h_time" ] && five_h_reset_str=$(printf " ${DIM}(%s)${NC}" "$five_h_time")
  [ -n "$seven_d_time" ] && seven_d_reset_str=$(printf " ${DIM}(%s)${NC}" "$seven_d_time")
  usage_section=$(printf " ${DIVIDER} ${DIM}Usage${NC} ${five_h_color}%d%%${NC}%s ${DIM}/${NC} ${seven_d_color}%d%%${NC}%s" \
    "$five_h" "$five_h_reset_str" "$seven_d" "$seven_d_reset_str")
fi

printf "${DIM}%s${NC} ${DIVIDER} ${DIM}Context${NC} ${color}%s${GRAY}%s${NC} ${DIM}%s/%s${NC} ${DIM}(%d%%)${NC}%s" \
  "$model" "$bar_filled" "$bar_empty" "$used_fmt" "$total_fmt" "$pct" "$usage_section"
