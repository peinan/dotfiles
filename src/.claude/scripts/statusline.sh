#!/usr/bin/env bash

NC="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
PURPLE="\033[38;5;105m"
GRAY="\033[38;5;241m"

# Nerd Font icons as UTF-8 escapes (private-use glyphs get stripped by some tools);
# printf expands them like the colors above
ICON_MODEL="\xf3\xb0\x9a\xa9"    # nf-md-robot
ICON_CONTEXT="\xf3\xb0\xa7\x91"  # nf-md-brain
ICON_CREDITS="\xef\x8a\x83"      # nf-fa-credit_card_alt

# Gap between sections, drawn in gray: " ∣ " for a bar, " " for a single space
SEPARATOR=" "
DIVIDER="${GRAY}${SEPARATOR}${NC}"

# Monthly usage credits come from the usage API, which is rate-limited and shared by
# every session, so one cached response serves all status lines
CREDITS_CACHE="${TMPDIR:-/tmp}/claude-statusline-credits.json"
CREDITS_TTL=300      # seconds between fetches
CREDITS_MAX_AGE=900  # hide the monthly figure once the last successful fetch is older

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "unknown"' | sed -E 's/ \([^)]+\)$//')
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

# Fetch in the background so the status line never waits on the network. Touching the
# cache first claims the next TTL window, so a burst of redraws fetches only once.
refresh_credits_cache() {
  local version=$1
  touch "$CREDITS_CACHE"
  (
    token=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null \
      | jq -r '.claudeAiOauth.accessToken // empty')
    [ -z "$token" ] && exit
    # The usage API answers other User-Agents with 429, so present as Claude Code.
    # The token goes in on stdin (-H @-) to keep it out of the process list.
    response=$(printf 'Authorization: Bearer %s\n' "$token" \
      | curl -sf --max-time 5 -H @- \
          -H "anthropic-beta: oauth-2025-04-20" \
          -H "User-Agent: claude-code/${version}" \
          https://api.anthropic.com/api/oauth/usage) || exit
    # Stamp the fetch time: the cache mtime only records the last attempt
    credits=$(echo "$response" | jq -ce '.extra_usage // empty | . + {fetched_at: now}') || exit
    echo "$credits" > "$CREDITS_CACHE.$$" && mv -f "$CREDITS_CACHE.$$" "$CREDITS_CACHE"
  ) >/dev/null 2>&1 &
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
  usage_section=$(printf "${DIVIDER}${DIM}Usage${NC} ${five_h_color}%d%%${NC}%s ${DIM}/${NC} ${seven_d_color}%d%%${NC}%s" \
    "$five_h" "$five_h_reset_str" "$seven_d" "$seven_d_reset_str")
fi

# --- Credits (session cost from stdin, monthly usage credits from the cache) ---
credits_section=""
session_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
version=$(echo "$input" | jq -r '.version // empty')

# BSD stat by absolute path: GNU coreutils' stat may shadow it in PATH
cache_mtime=$(/usr/bin/stat -f %m "$CREDITS_CACHE" 2>/dev/null || echo 0)
if [ -n "$version" ] && [ $(( $(date +%s) - cache_mtime )) -ge "$CREDITS_TTL" ]; then
  refresh_credits_cache "$version"
fi

read -r monthly_used monthly_pct <<< "$(jq -r --argjson max_age "$CREDITS_MAX_AGE" '
  select(.currency == "USD" and now - .fetched_at < $max_age)
  | "\(.used_credits / pow(10; .decimal_places // 2)) \(.utilization | floor)"
' "$CREDITS_CACHE" 2>/dev/null)"

if [ -n "$session_cost" ]; then
  credits_section=$(printf "${DIVIDER}${DIM}${ICON_CREDITS}${NC}  \$%.2f" "$session_cost")
  if [ -n "$monthly_used" ]; then
    monthly_color=$(color_for_pct "$monthly_pct")
    credits_section+=$(printf " ${monthly_color}\$%.2f${NC} ${DIM}(%d%%)${NC}" "$monthly_used" "$monthly_pct")
  fi
fi

printf "${DIM}${ICON_MODEL}  %s${NC}${DIVIDER}${DIM}${ICON_CONTEXT}${NC}  ${color}%s${GRAY}%s${NC} ${DIM}%s/%s${NC} ${DIM}(%d%%)${NC}%s%s" \
  "$model" "$bar_filled" "$bar_empty" "$used_fmt" "$total_fmt" "$pct" "$usage_section" "$credits_section"
