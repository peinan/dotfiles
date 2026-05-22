#!/usr/bin/env bash
# SessionStart hook: ensure project has .claude/settings.local.json with
# plansDirectory pointing to ~/.claude/plans/<basename>.
#
# Writes to settings.local.json (gitignored by default) so the absolute path
# containing $HOME is not committed.
#
# No-op when:
#   - cwd is outside a git repo
#   - .claude/settings.local.json already exists at the repo root

set -u

project_root="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0

target="$project_root/.claude/settings.local.json"
[[ -e "$target" ]] && exit 0

name="${project_root##*/}"
plans_dir="$HOME/.claude/plans/$name"

mkdir -p "$project_root/.claude" "$plans_dir"
cat > "$target" <<EOF
{
  "plansDirectory": "$plans_dir"
}
EOF

echo "init-plans-dir: created $target -> $plans_dir" >&2
