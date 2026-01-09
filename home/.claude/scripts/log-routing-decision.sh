#!/bin/bash
# Log routing decisions for Claude Code hooks
# Usage: log-routing-decision.sh <decision> <event_type> <tool_or_action> [file_path]

DECISION="$1"
EVENT_TYPE="$2"
TOOL_OR_ACTION="$3"
FILE_PATH="${4:-N/A}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG_FILE="$HOME/.claude/routing-audit.log"

# Create log entry
echo "$TIMESTAMP | $DECISION | $EVENT_TYPE | $TOOL_OR_ACTION | $FILE_PATH" >> "$LOG_FILE"
