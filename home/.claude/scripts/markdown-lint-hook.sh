#!/usr/bin/env bash
#
# Markdown Linting Hook
# Automatically fixes markdown issues after file edits
#
# Usage: markdown-lint-hook.sh <file_path>

set -euo pipefail

FILE_PATH="${1:-}"

# Exit silently if no file path provided
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Only process markdown files
if [[ ! "$FILE_PATH" =~ \.md$ ]]; then
  exit 0
fi

# Check if file exists
if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Check if markdownlint-cli2 is installed
if ! command -v markdownlint-cli2 &> /dev/null; then
  # Silently skip if not installed (user can install manually or via agent)
  exit 0
fi

# Run markdownlint with auto-fix (suppress output unless error)
if markdownlint-cli2 --fix "$FILE_PATH" &> /dev/null; then
  # Success - file was linted (possibly fixed)
  exit 0
else
  # Error occurred - still exit 0 to not block the main operation
  exit 0
fi
