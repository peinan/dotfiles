#!/usr/bin/env bash
set -euo pipefail

for cmd in aicommit2 jq fzf; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "$cmd is required"
    exit 1
  fi
done

gen_script="$(mktemp -t lazygit-aicommit-gen.XXXXXX)"
cleanup() {
  rm -f "$gen_script"
}
trap cleanup EXIT INT TERM

cat >"$gen_script" <<'GEN'
#!/usr/bin/env bash
set -euo pipefail
aicommit2 -i --output json 2>/dev/null \
  | jq -r '["\(.subject) | \(.body | split("\n")[0])", (.subject | @json), (.body | @json)] | join("\u001f")'
GEN
chmod +x "$gen_script"

selected="$(
  echo | fzf \
    --prompt="AI commit> " \
    --header="Select a message" \
    --height=100% \
    --layout=reverse \
    --info=default \
    --delimiter=$'\x1f' \
    --with-shell="bash --noprofile --norc -c" \
    --preview-window="right:60%:wrap" \
    --preview 'printf "%s" {} | jq -Rr "split(\"\\u001f\") | (.[1] | fromjson), \"\", (.[2] | fromjson)" 2>/dev/null' \
    --bind "load:unbind(load)+reload-sync($gen_script)"
)" || exit 0

[ -n "$selected" ] || exit 0

subject="$(printf "%s" "$selected" | jq -Rr 'split("\u001f")[1] | fromjson')"
body="$(printf "%s" "$selected" | jq -Rr 'split("\u001f")[2] | fromjson')"

git commit -e -m "$subject" -m "$body"
