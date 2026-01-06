#!/usr/bin/env bash
#
# Detect and auto-fix email addresses in files to prevent accidental commits of personal information.
#
# Exit codes:
#   0 - No issues found (or already clean)
#   1 - Files were modified (need to re-stage)

set -euo pipefail

# Email regex pattern
EMAIL_PATTERN='[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'

modified=0

for file in "$@"; do
    if [[ ! -f "$file" ]]; then
        continue
    fi

    file_modified=0

    # Check for Google Drive paths with email addresses and fix them
    # Pattern: ${HOME}/Google Drive/... -> ${HOME}/Google Drive/...
    if grep -qE '\$\{HOME\}/[^"]*@[^"]*- Google Drive' "$file" 2>/dev/null; then
        echo "Fixing Google Drive paths in $file..."

        # Remove gd2, gd3 lines (keep only gd)
        sed -i '' '/^hash -d gd[0-9]=/d' "$file"

        # Fix remaining Google Drive path (remove email prefix)
        sed -i '' 's|\${HOME}/[^"]*@[^"]*- Google Drive|\${HOME}/Google Drive|g' "$file"

        file_modified=1
    fi

    # Check for any remaining email addresses
    if grep -qE "$EMAIL_PATTERN" "$file" 2>/dev/null; then
        echo "WARNING: Email addresses still found in $file:"
        grep -nE "$EMAIL_PATTERN" "$file" | while read -r line; do
            echo "  $line"
        done
        echo ""
        echo "Please manually remove these email addresses."
        modified=1
    elif [[ $file_modified -eq 1 ]]; then
        modified=1
    fi
done

if [[ $modified -eq 1 ]]; then
    echo ""
    echo "Files were modified. Please review changes and re-stage with 'git add'."
    exit 1
fi

exit 0
