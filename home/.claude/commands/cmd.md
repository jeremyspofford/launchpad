---
description: Manage custom slash commands - create, list, edit, delete, and run
allowed-tools: Bash, Read, Write, Edit, Glob
argument-hint: <action> [command-name] - actions: create, list, edit, delete, run
---

I'll help you manage your custom slash commands based on your request: **$ARGUMENTS**

## Slash Command Manager

### Available Actions:
1. **create** - Create a new slash command
2. **list** - List all available custom slash commands
3. **edit <name>** - Edit an existing slash command  
4. **delete <name>** - Delete a slash command
5. **run <name>** - Show how to execute a slash command

Let me process your request for: `$ARGUMENTS`

Based on your arguments, I'll:

1. **Parse the action** from your input
2. **Search for existing commands** in both project (.claude/commands/) and personal (~/.claude/commands/) directories
3. **Perform the requested operation**

If you didn't provide arguments or need help, here's how to use this command:
- `/cmd create` - I'll guide you through creating a new command
- `/cmd create mycommand` - Create a command named "mycommand"
- `/cmd list` - Show all available slash commands
- `/cmd edit mycommand` - Edit the "mycommand" slash command
- `/cmd delete mycommand` - Delete the "mycommand" slash command  
- `/cmd run mycommand` - Show how to execute "mycommand"

I'll now analyze your request and provide the appropriate response or perform the requested action.