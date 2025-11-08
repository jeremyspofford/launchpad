#!/usr/bin/env bash
#
# log-routing-decision.sh - Logs routing decisions for audit trail
#

set -euo pipefail

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
ROUTING_METHOD="${1:-UNKNOWN}"
TASK_TYPE="${2:-general}"
TOOL_USED="${3:-unknown}"
FILE_PATH="${4:-}"

LOG_FILE="$HOME/.claude/routing-audit.log"
LOG_DIR=$(dirname "$LOG_FILE")

# Ensure directory exists
mkdir -p "$LOG_DIR"

# Append to log
# Note: flock not available on macOS, using simple append for single-user system
echo "$TIMESTAMP | $ROUTING_METHOD | $TASK_TYPE | $TOOL_USED | $FILE_PATH" >> "$LOG_FILE"
