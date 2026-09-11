#!/usr/bin/env bash
#
# Refuse to commit values that must not appear in a public repository.
#
# Two kinds of value qualify. The first identifies an account — a mail address,
# an API token, a private key — and has a recognisable shape, so it is matched
# by the built-in patterns below. The second is a name that belongs to a
# non-public environment, which has no shape at all; listing those names in a
# tracked file would publish exactly what the check exists to protect, so they
# are read from a file outside the repository instead.
#
# This only detects. The Google Drive paths it used to rewrite now live in
# ~/.alias.local, so there is nothing left to fix in place — and silently
# deleting lines from a commit is the wrong answer for anything else.
#
# Exit codes:
#   0 - nothing found
#   1 - something found, or a configured pattern file could not be read

set -euo pipefail

# Fixed strings that are deliberately public, one per line. A matched line
# containing any of them is ignored, so keep this to values that appear on a
# line of their own. The Git author address is here because it is already in
# the author field of every commit this repository contains.
readonly ALLOWED='peinan7@gmail.com'

# Site-specific patterns, kept outside the repository. One extended regex per
# line. Absent on a machine that has none, which is not an error.
readonly EXTRA_PATTERNS="${DOTFILES_SECRET_PATTERNS:-$HOME/.config/dotfiles/secret-patterns}"

# Shapes that are secret wherever they appear.
readonly BUILTIN_PATTERNS='[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}
BEGIN [A-Z ]*PRIVATE KEY
ghp_[A-Za-z0-9]{36}
github_pat_[A-Za-z0-9_]{22,}
sk-[A-Za-z0-9]{20,}
AKIA[0-9A-Z]{16}
xox[baprs]-[A-Za-z0-9-]{10,}'

BUILTIN_ALTERNATION="$(printf '%s' "$BUILTIN_PATTERNS" | paste -sd'|' -)"
readonly BUILTIN_ALTERNATION

if [[ -e "$EXTRA_PATTERNS" && ! -r "$EXTRA_PATTERNS" ]]; then
    echo "secret-guard: $EXTRA_PATTERNS exists but cannot be read" >&2
    exit 1
fi

found=0

for file in "$@"; do
    [[ -f "$file" ]] || continue

    hits="$(grep -nE "$BUILTIN_ALTERNATION" "$file" 2>/dev/null || true)"

    if [[ -r "$EXTRA_PATTERNS" ]]; then
        # A blank line in the pattern file would match every line, so drop
        # blanks and comments before handing it to grep.
        extra_hits="$(grep -vE '^[[:space:]]*($|#)' "$EXTRA_PATTERNS" 2>/dev/null \
            | grep -nEf - "$file" 2>/dev/null || true)"
        if [[ -n "$extra_hits" ]]; then
            hits="$(printf '%s\n%s' "$hits" "$extra_hits")"
        fi
    fi

    # Drop lines that are allowed outright.
    if [[ -n "$hits" ]]; then
        hits="$(printf '%s' "$hits" | grep -vF "$ALLOWED" || true)"
    fi

    hits="$(printf '%s' "$hits" | grep -v '^[[:space:]]*$' || true)"

    if [[ -n "$hits" ]]; then
        echo "secret-guard: $file"
        printf '%s\n' "$hits" | sed 's/^/    /'
        found=1
    fi
done

if [[ $found -eq 1 ]]; then
    cat >&2 <<'MSG'

This repository is public, so the values above cannot be committed here.

Move the value to the private overrides repository and load it from there:

  - shell aliases          ~/.alias.local
  - anything else in zsh   ~/.zsh/local/<concern>.zsh

Both are read only if present, so nothing breaks on a machine without them.

If the value is deliberately public, add it to ALLOWED in this script. If it
is a name rather than a shape, and should be caught on this machine only, add
the pattern to the file named by DOTFILES_SECRET_PATTERNS.
MSG
    exit 1
fi

exit 0
