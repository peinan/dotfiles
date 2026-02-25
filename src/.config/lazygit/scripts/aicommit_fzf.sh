#!/usr/bin/env bash
set -euo pipefail

for cmd in aicommit2 jq fzf curl; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "$cmd is required"
    exit 1
  fi
done

done_file="$(mktemp -t lazygit-aicommit-done.XXXXXX)"
spinner_script="$(mktemp -t lazygit-aicommit-spinner.XXXXXX)"
gen_script="$(mktemp -t lazygit-aicommit-gen.XXXXXX)"
cleanup() {
  touch "$done_file" >/dev/null 2>&1 || true
  rm -f "$done_file" "$spinner_script" "$gen_script"
}
trap cleanup EXIT INT TERM

cat >"$spinner_script" <<'SPIN'
#!/usr/bin/env bash
set -euo pipefail
frames=("⠋" "⠙" "⠹" "⢸" "⣸" "⣰" "⣤" "⣆" "⡇" "⠏")
i=0
while [ ! -f "$DONE_FILE" ]; do
  c="${frames[i]}"
  curl -fsS -X POST "http://127.0.0.1:${FZF_PORT}" --data-binary "change-prompt(${c} Generating... )" >/dev/null 2>&1 || break
  i=$(((i + 1) % ${#frames[@]}))
  sleep 0.08
done
SPIN
chmod +x "$spinner_script"
export DONE_FILE="$done_file"

cat >"$gen_script" <<'GEN'
#!/usr/bin/env bash
set -euo pipefail
aicommit2 -i --output json 2>/dev/null \
  | jq -r '["\(.subject) | \(.body | split("\n")[0])", (.subject | @json), (.body | @json)] | join("\u001f")'
GEN
chmod +x "$gen_script"

selected="$(
  fzf \
    --listen 0 \
    --disabled \
    --prompt="Generating... " \
    --header="Generating commit suggestions..." \
    --height=~100% \
    --layout=reverse \
    --border \
    --info=inline \
    --delimiter=$'\x1f' \
    --with-shell="bash --noprofile --norc -c" \
    --preview-window="right:60%:wrap" \
    --preview 'printf "%s" {} | jq -Rr "split(\"\\u001f\") | (.[1] | fromjson), \"\", (.[2] | fromjson)" 2>/dev/null' \
    --bind "start:execute-silent($spinner_script)+reload($gen_script)" \
    --bind "load:execute-silent(touch $done_file)+change-prompt(AI commit> )+change-header(Select a message)+enable-search" \
    < /dev/null
)" || exit 0

[ -n "$selected" ] || exit 0

subject="$(printf "%s" "$selected" | jq -Rr 'split("\u001f")[1] | fromjson')"
body="$(printf "%s" "$selected" | jq -Rr 'split("\u001f")[2] | fromjson')"

git commit -e -m "$subject" -m "$body"
