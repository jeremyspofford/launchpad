---
description: Sync Claude Code configurations to Cursor IDE format (AGENTS.md, .cursor/rules, slash commands, hooks, MCP configs, custom agent modes)
---

# Sync Claude Code Configurations to Cursor IDE

Use the cursor-config-sync agent to translate your Claude Code configurations to Cursor IDE-compatible formats.

## What This Does

The cursor-config-sync agent will:

- ✅ Read your Claude Code configurations (CLAUDE.md, skills, agents, commands, hooks, MCP servers)
- ✅ Generate Cursor-compatible files:
  - `AGENTS.md` (universal AI assistant instructions)
  - `.cursor/rules/*.mdc` (specialized rules from your skills)
  - `~/.cursor/commands/*.md` (slash commands with frontmatter stripped)
  - `~/.cursor/hooks.json` (hooks converted with event mapping)
  - `~/.cursor/mcp.json` (global MCP servers)
  - `.cursor/mcp.json` (project MCP servers)
  - `cursor-agent-configs/*.json` (custom agent mode configurations)
  - `sync-cursor-configs.sh` (re-sync script)
- ✅ **Never modifies your original Claude Code configs**

## Task Instructions

**IMPORTANT**: You must now invoke the cursor-config-sync agent to perform the configuration sync.

Use the Task tool with:

- `subagent_type: "cursor-config-sync"`
- `description: "Sync Claude Code configs to Cursor"`
- `prompt: "Generate Cursor IDE-compatible configurations from my Claude Code setup. Read all Claude Code configs from ~/.claude/ and generate corresponding Cursor configs for the current project directory. This includes AGENTS.md, .cursor/rules/*.mdc files, slash commands (with frontmatter stripped), hooks (with event mapping and structure conversion), MCP configs, custom agent mode JSONs, sync script, and documentation. Do not modify any original Claude Code files - only read them and create new Cursor-compatible files."`
- `model: "haiku"` (this is straightforward file transformation)

The agent will:

1. Analyze Claude Code configurations
2. Generate all Cursor-compatible files
3. Provide a summary and next steps
4. Include instructions for manual setup in Cursor UI
