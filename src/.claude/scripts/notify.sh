#!/usr/bin/env zsh
# Claude Code notification script
# Reads hook event from stdin and displays a rich notification

set -euo pipefail
# set -x  # for debug

readonly LOG_FILE="$HOME/.claude/notification-log.txt"

sanitize_control_chars() {
    LC_ALL=C tr -d '\000-\010\013-\037'
}

safe_jq_input() {
    local filter="$1"
    local fallback="${2:-}"
    local out=""

    out=$(printf '%s' "$input" | jq -r "$filter" 2>/dev/null || true)
    if [[ -z "$out" ]]; then
        printf '%s' "$fallback"
        return 0
    fi

    printf '%s' "$out"
}

shorten_path() {
    local path="$1"
    local result=""
    local part=""
    local parts=()
    local i=0
    local last_idx=0

    path="${path/#$HOME/~}"
    parts=("${(@s:/:)path}")
    last_idx=${#parts[@]}

    for ((i = 1; i <= last_idx; i++)); do
        part="${parts[$i]}"
        [[ -z "$part" ]] && continue

        if [[ $i -eq $last_idx ]]; then
            result+="$part"
        else
            result+="${part[1]}/"
        fi
    done

    printf '%s' "$result"
}

extract_recent_activity() {
    local transcript="$1"
    local tools=""
    local last_text=""
    local activity=""

    [[ -f "$transcript" ]] || {
        printf ''
        return 0
    }

    tools=$(tail -20 "$transcript" 2>/dev/null | \
            sanitize_control_chars | \
            jq -r 'select(.type == "assistant") | .message.content[]? | select(.type == "tool_use") | .name' 2>/dev/null | \
            sort | uniq -c | sort -rn | head -3 | \
            awk '{printf "%s(%d) ", $2, $1}' || true)

    last_text=$(tail -50 "$transcript" 2>/dev/null | \
            sanitize_control_chars | \
            jq -r 'select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text' 2>/dev/null | \
            tail -1 | head -c 100 || true)

    if [[ -n "$tools" ]]; then
        activity="Tools: ${tools}"
    fi

    if [[ -n "$last_text" && ${#last_text} -gt 10 ]]; then
        last_text=$(printf '%s' "$last_text" | tr '\n' ' ' | head -c 80)
        activity+="${activity:+$'\n'}${last_text}..."
    fi

    printf '%s' "$activity"
}

resolve_notification_style() {
    case "$hook_event" in
        "Notification")
            case "$notification_type" in
                "permission_prompt") title="⚠︎ Permission Required" ;;
                "idle_prompt") title="⌚︎ Waiting for Input" ;;
                "elicitation_dialog") title="⊙ Question" ;;
                *) title="❇︎ Information" ;;
            esac
            ;;
        "Stop") title="✔︎  Task Completed" ;;
        *) title="❖  Claude Code" ;;
    esac

    subtitle="\[$project_path]"
}

build_notification_body() {
    local activity=""
    body="$message"

    if [[ -n "$transcript_path" ]]; then
        activity=$(extract_recent_activity "$transcript_path")
        if [[ -n "$activity" ]]; then
            if [[ -n "$body" ]]; then
                body+=$'\n---\n'"$activity"
            else
                body="$activity"
            fi
        fi
    fi
}

send_notification() {
    if command -v terminal-notifier &>/dev/null; then
        terminal-notifier \
            -title "$title" \
            -subtitle "$subtitle" \
            -message "$body" \
            -sound "Funk" \
            -group "claude-code-$session_id-$(date +%s)" \
            -activate "com.mitchellh.ghostty" || true
        return 0
    fi

    escape_for_applescript() {
        printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
    }

    local title_escaped
    local subtitle_escaped
    local body_escaped

    title_escaped=$(escape_for_applescript "$title")
    subtitle_escaped=$(escape_for_applescript "$subtitle")
    body_escaped=$(escape_for_applescript "$body")

    osascript -e "display notification \"$body_escaped\" with title \"$title_escaped\" subtitle \"$subtitle_escaped\" sound name \"Funk\"" || true
}

can_write_log_file() {
    local log_dir="${LOG_FILE:h}"
    if [[ -e "$LOG_FILE" ]]; then
        [[ -w "$LOG_FILE" ]]
        return $?
    fi
    [[ -d "$log_dir" && -w "$log_dir" ]]
}

write_log() {
    can_write_log_file || return 0
    if ! printf '%s' "$input" | jq -c --arg t "$title" --arg b "$body" '. + {displayed_title: $t, displayed_body: $b}' >> "$LOG_FILE" 2>/dev/null; then
        printf '%s\t%s\t%s\n' "$(date '+%Y-%m-%d %H:%M:%S%z')" "$title" "$body" >> "$LOG_FILE" 2>/dev/null || true
    fi
}

# Read JSON from stdin and sanitize control characters that break jq parsing.
# Claude Code may embed raw control chars (U+0000-U+001F) in message fields.
# Strip all except \t (0x09) and \n (0x0a) which jq tolerates as whitespace.
input=$(sanitize_control_chars < /dev/stdin)

hook_event=$(safe_jq_input '.hook_event_name // "Unknown"' "Unknown")
notification_type=$(safe_jq_input '.notification_type // ""' "")
message=$(safe_jq_input '.message // ""' "")
cwd=$(safe_jq_input '.cwd // ""' "")
transcript_path=$(safe_jq_input '.transcript_path // ""' "")
session_id=$(safe_jq_input '.session_id // ""' "")

project_path=$(shorten_path "$cwd")
title=""
subtitle=""
body=""

resolve_notification_style
build_notification_body

echo "subtitle=$subtitle"
send_notification
write_log

exit 0
