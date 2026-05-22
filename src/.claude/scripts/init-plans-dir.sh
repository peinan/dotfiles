#!/usr/bin/env bash
# SessionStart hook: ensure project has .claude/settings.json with plansDirectory
# pointing to ~/.claude/plans/<basename>.
#
# No-op when:
#   - cwd is outside a git repo
#   - .claude/settings.json already exists at the repo root

set -u

project_root="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0

target="$project_root/.claude/settings.json"
[[ -e "$target" ]] && exit 0

name="${project_root##*/}"
plans_dir="$HOME/.claude/plans/$name"

mkdir -p "$project_root/.claude" "$plans_dir"
cat > "$target" <<EOF
{
  "plansDirectory": "~/.claude/plans/$name"
}
EOF

echo "init-plans-dir: created $target -> ~/.claude/plans/$name" >&2
