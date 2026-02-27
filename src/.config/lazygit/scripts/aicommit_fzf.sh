#!/usr/bin/env bash
set -euo pipefail

for cmd in aicommit2 jq fzf; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "$cmd is required"
    exit 1
  fi
done

results_file="$(mktemp -t lazygit-aicommit-results.XXXXXX)"
trap 'rm -f "$results_file"' EXIT INT TERM

selected="$(
  echo | fzf \
    --prompt="AI commit> " \
    --header="Select a message" \
    --height=100% \
    --layout=reverse \
    --info=inline \
    --with-nth=2.. \
    --delimiter=$'\t' \
    --with-shell="bash --noprofile --norc -c" \
    --preview-window="right:60%:wrap" \
    --preview "jq -r '.[ {1} ] | \"\(.subject)\n\n\(.body)\"' $results_file" \
    --bind "load:unbind(load)+reload-sync#aicommit2 -i --output json 2>/dev/null | jq -s '.' > $results_file && jq -r 'to_entries[] | \"\\(.key)\\t\\(.value.subject)\"' $results_file#"
)" || exit 0

[ -n "$selected" ] || exit 0

index="${selected%%$'\t'*}"
subject="$(jq -r ".[$index].subject" "$results_file")"
body="$(jq -r ".[$index].body" "$results_file")"

git commit -e -m "$subject" -m "$body"
