#!/usr/bin/env bash

GREEN='\033[01;32m'
CYAN='\033[0;36m'
BLUE='\033[01;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET='\033[00m'

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
current_dir=$(basename "$cwd")

output="${GREEN}➜${RESET}  ${CYAN}${current_dir}${RESET}"

if [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)

    if [ -n "$branch" ]; then
        if ! git -C "$cwd" --no-optional-locks diff --quiet 2>/dev/null || ! git -C "$cwd" --no-optional-locks diff --cached --quiet 2>/dev/null; then
            output="${output} ${BLUE}git:(${RED}${branch}${BLUE})${RESET} ${YELLOW}✗${RESET}"
        else
            output="${output} ${BLUE}git:(${RED}${branch}${BLUE})${RESET}"
        fi
    fi
fi
printf "%b" "$output"
