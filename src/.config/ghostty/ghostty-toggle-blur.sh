#!/usr/bin/env bash
# @raycast.schemaVersion 1
# @raycast.title Toggle Ghostty Blur
# @raycast.mode silent
# @raycast.packageName Ghostty
# @raycast.icon 🪄
# @raycast.argument1 { "type": "text", "optional": true }

exec 2>>"$HOME/.config/ghostty/ghostty-toggle.err"
set -euo pipefail
set -x

# PATH 明示
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

CFG_DIR="$HOME/.config/ghostty"
SWITCH_FILE="$CFG_DIR/background-control"

current=$(grep -E '^config-file[[:space:]]*=' "$SWITCH_FILE" | sed -E 's/.*= *//')
if [[ "$current" == "bg-blur" ]]; then
    next="bg-trans"
else
    next="bg-blur"
fi

# debugging
# res=$(sed -E "s/^config\-file[[:space:]]*=[[:space:]]*${current}/config-file = ${next}/" "$SWITCH_FILE")
# echo "$current $next"
# echo $res

sed -E -i "" "s/^config\-file[[:space:]]*=[[:space:]]*${current}/config-file = ${next}/" "$SWITCH_FILE"

# Ghostty にリロードを送る（Cmd+Shift+,）
/usr/bin/osascript <<'APPLESCRIPT'
-- Ghostty が起動しているかアプリケーション辞書で判定
if application "Ghostty" is running then
    tell application "System Events"
        -- UI 要素にアクセスするための前提（要アクセシビリティ許可）
        if not UI elements enabled then
            -- Monterey 以降は常に true だが、念のため
        end if
        -- プロセス名は Dock に表示されるアプリ名と一致させる
        tell application process "Ghostty"
            set frontmost to true
            keystroke "," using {command down, shift down}
        end tell
    end tell
else
    -- 必要なら起動する
    -- tell application "Ghostty" to activate
end if
APPLESCRIPT


# うまく反映されない場合のフォールバック（必要ならコメント解除）
# pkill -x Ghostty; open -a Ghostty

