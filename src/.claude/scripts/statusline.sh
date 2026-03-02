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

USAGE_CACHE="/tmp/claude-usage-cache.json"
USAGE_TTL=60

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

fetch_usage() {
  # Check cache freshness
  if [ -f "$USAGE_CACHE" ]; then
    local now mtime age
    now=$(date +%s)
    mtime=$(stat -c %Y "$USAGE_CACHE" 2>/dev/null || stat -f %m "$USAGE_CACHE" 2>/dev/null || echo 0)
    age=$(( now - mtime ))
    if [ "$age" -lt "$USAGE_TTL" ]; then
      cat "$USAGE_CACHE"
      return
    fi
  fi

  # Get OAuth token
  local token_json access_token
  token_json=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null) || return 1
  access_token=$(echo "$token_json" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
  [ -z "$access_token" ] && return 1

  # Fetch usage data
  local response
  response=$(curl -s --max-time 5 https://api.anthropic.com/api/oauth/usage \
    -H "Authorization: Bearer $access_token" \
    -H "anthropic-beta: oauth-2025-04-20" \
    -H "Content-Type: application/json" 2>/dev/null)

  # Validate response
  if echo "$response" | jq -e '.five_hour.utilization' >/dev/null 2>&1; then
    echo "$response" > "$USAGE_CACHE"
    echo "$response"
  elif [ -f "$USAGE_CACHE" ]; then
    # API failed, use stale cache
    cat "$USAGE_CACHE"
  else
    return 1
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

# --- Usage limits ---
usage_section=""
usage_data=$(fetch_usage 2>/dev/null)
if [ -n "$usage_data" ]; then
  five_h=$(echo "$usage_data" | jq -r '.five_hour.utilization // empty | floor' 2>/dev/null)
  seven_d=$(echo "$usage_data" | jq -r '.seven_day.utilization // empty | floor' 2>/dev/null)

  if [ -n "$five_h" ] && [ -n "$seven_d" ]; then
    five_h_color=$(color_for_pct "$five_h")
    seven_d_color=$(color_for_pct "$seven_d")
    usage_section=$(printf " ${DIVIDER} ${DIM}Usage${NC} ${five_h_color}%d%%${NC} ${DIM}/${NC} ${seven_d_color}%d%%${NC}" \
      "$five_h" "$seven_d")
  fi
fi

printf "${DIM}%s${NC} ${DIVIDER} ${DIM}Context${NC} ${color}%s${GRAY}%s${NC} ${DIM}%s/%s${NC} ${DIM}(%d%%)${NC}%s" \
  "$model" "$bar_filled" "$bar_empty" "$used_fmt" "$total_fmt" "$pct" "$usage_section"
