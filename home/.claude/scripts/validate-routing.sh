#!/usr/bin/env bash
#
# validate-routing.sh - Enforces orchestrator-first routing policy
# Returns 0 to allow operation, 1 to block
#

set -euo pipefail

TOOL_NAME="${1:-unknown}"
FILE_PATH="${2:-}"

# Allow if routed via orchestrator
if [[ "${ROUTED_VIA_ORCHESTRATOR:-0}" == "1" ]]; then
    exit 0
fi

# Technical file extensions that require orchestrator
TECHNICAL_PATTERNS=(
    '\\.md$'
    '\\.json$'
    '\\.ts$'
    '\\.tsx$'
    '\\.js$'
    '\\.jsx$'
    '\\.py$'
    '\\.sh$'
    '\\.bash$'
    '\\.yaml$'
    '\\.yml$'
    'agents/'
    'scripts/'
    '.claude/'
)

# Check if this is a technical edit operation
if [[ "$TOOL_NAME" =~ ^(Edit|Write|MultiEdit)$ ]]; then
    # Check if file matches technical patterns
    for pattern in "${TECHNICAL_PATTERNS[@]}"; do
        if [[ "$FILE_PATH" =~ $pattern ]]; then
            cat >&2 <<EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛑 ORCHESTRATOR-FIRST ROUTING POLICY VIOLATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Tool: $TOOL_NAME
File: $FILE_PATH

Technical work must be routed through orchestrator-agent.

Correct usage:

  Task({
    subagent_type: "orchestrator-agent",
    description: "Brief description",
    prompt: "[Your full request here]"
  })

The orchestrator will:
- Coordinate appropriate sub-agents
- Run parallel operations where possible
- Synthesize results into coherent reports
- Verify changes work correctly

Emergency bypass: export ROUTED_VIA_ORCHESTRATOR=1

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
            exit 1
        fi
    done
fi

# Allow non-technical operations
exit 0
