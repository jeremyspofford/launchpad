#!/usr/bin/env bash

# doc-update-hook.sh - Hook script to suggest documentation updates after code changes
# This script is triggered by Claude Code hooks when files are modified

set -e

# Colors for output
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Get the file path from the first argument (passed by Claude Code hook)
FILE_PATH="$1"

# If no file path provided, exit
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Extract file extension
FILE_EXT="${FILE_PATH##*.}"

# Check if this is a code file that might need documentation updates
case "$FILE_EXT" in
    py|js|ts|jsx|tsx|go|rs|java|c|cpp|h|hpp|rb|php|swift|kt|scala|sh|bash)
        # This is a code file
        ;;
    md|txt|rst|adoc)
        # This is already a documentation file, skip
        exit 0
        ;;
    *)
        # Unknown file type, skip
        exit 0
        ;;
esac

# Check if the file is a test file (usually doesn't need doc updates)
if [[ "$FILE_PATH" == *test* ]] || [[ "$FILE_PATH" == *spec* ]]; then
    exit 0
fi

# Get the directory of the changed file
FILE_DIR="$(dirname "$FILE_PATH")"
FILE_NAME="$(basename "$FILE_PATH")"

# Look for related documentation files
DOC_FILES=()

# Check for README in the same directory
if [ -f "$FILE_DIR/README.md" ]; then
    DOC_FILES+=("$FILE_DIR/README.md")
fi

# Check for docs directory at various levels
for dir in "$FILE_DIR" "$FILE_DIR/.." "$FILE_DIR/../.." "$(pwd)"; do
    if [ -d "$dir/docs" ]; then
        # Find all markdown files in docs directory
        while IFS= read -r -d '' doc_file; do
            DOC_FILES+=("$doc_file")
        done < <(find "$dir/docs" -name "*.md" -print0 2>/dev/null)
        break
    fi
done

# Check for API documentation
if [[ "$FILE_PATH" == *api* ]] || [[ "$FILE_PATH" == *endpoint* ]] || [[ "$FILE_PATH" == *route* ]]; then
    for api_doc in "$(pwd)/API.md" "$(pwd)/docs/API.md" "$(pwd)/docs/api.md"; do
        if [ -f "$api_doc" ]; then
            DOC_FILES+=("$api_doc")
        fi
    done
fi

# Check for configuration documentation
if [[ "$FILE_PATH" == *config* ]] || [[ "$FILE_PATH" == *.env* ]]; then
    for config_doc in "$(pwd)/CONFIGURATION.md" "$(pwd)/docs/configuration.md" "$(pwd)/docs/config.md"; do
        if [ -f "$config_doc" ]; then
            DOC_FILES+=("$config_doc")
        fi
    done
fi

# If we found related documentation files, suggest updating them
if [ ${#DOC_FILES[@]} -gt 0 ]; then
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2
    echo -e "${YELLOW}📝 Documentation Update Reminder${NC}" >&2
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2
    echo >&2
    echo -e "Modified: ${GREEN}$FILE_PATH${NC}" >&2
    echo >&2
    echo "Consider updating these related documentation files:" >&2
    
    # Remove duplicates and display
    printf '%s\n' "${DOC_FILES[@]}" | sort -u | while read -r doc; do
        echo "  • $(realpath --relative-to="$(pwd)" "$doc" 2>/dev/null || echo "$doc")" >&2
    done
    
    echo >&2
    echo "You can use the documentation-updater agent by saying:" >&2
    echo -e "${GREEN}  'Update the documentation to reflect changes in $FILE_NAME'${NC}" >&2
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2
fi