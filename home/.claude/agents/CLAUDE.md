---
name: "Global Configuration Agent"
description: "Global agent configuration for all Claude Code projects"

---

# Global Claude Code Agent Configuration

## Tool Permissions

### File System Operations

- Bash(find:*) - Allow find command for file searching
- Bash(locate:*) - Allow locate command for file searching
- Bash(which:*) - Allow which command to find executable locations
- Bash(whereis:*) - Allow whereis command to locate binaries/man pages

### Development Tools

- Bash(make:*) - Allow make command for build operations
- Bash(npm:*) - Allow npm package manager operations
- Bash(yarn:*) - Allow yarn package manager operations
- Bash(pip:*) - Allow pip Python package manager operations
- Bash(cargo:*) - Allow Rust cargo operations
- Bash(go:*) - Allow Go command operations

### Version Control

- Bash(git:*) - Allow all git operations (already permitted via default)

### System Information

- Bash(ps:*) - Allow process listing
- Bash(top:*) - Allow system monitoring
- Bash(htop:*) - Allow enhanced system monitoring
- Bash(df:*) - Allow disk usage checking
- Bash(du:*) - Allow directory usage checking
- Bash(free:*) - Allow memory usage checking

### Network Tools

- Bash(curl:*) - Allow curl for HTTP requests
- Bash(wget:*) - Allow wget for downloads
- Bash(ping:*) - Allow network connectivity testing
- Bash(nslookup:*) - Allow DNS lookups
- Bash(dig:*) - Allow DNS queries

### Text Processing

- Bash(awk:*) - Allow awk text processing
- Bash(sed:*) - Allow sed stream editing
- Bash(sort:*) - Allow sorting operations
- Bash(uniq:*) - Allow unique line operations
- Bash(wc:*) - Allow word/line counting

## Agent Behavior Preferences

### Code Style

- Prefer existing patterns and conventions in the codebase
- Always check for existing libraries before suggesting new ones
- Follow security best practices (no secrets in code/logs)

### Communication Style

- Be concise and direct
- Minimize unnecessary explanations unless requested
- Focus on solving the specific task at hand

### Task Management

- Use TodoWrite tool for complex multi-step tasks
- Mark tasks as completed immediately after finishing
- Break down large tasks into manageable steps

## MCP Tools Usage

### Context Awareness

- ALWAYS check available MCP tools using ListMcpResourcesTool at the start of conversations
- Understand the project context to intelligently select appropriate tools
- When working in AWS environments, proactively use AWS-related MCP tools
- Don't wait for explicit tool requests - use context to determine tool needs

### Memory Tool Protocol

Follow these steps for each interaction:

1. **User Identification**:
   - Assume interaction with default_user
   - If default_user not identified, proactively identify them

2. **Memory Retrieval**:
   - ALWAYS begin chat by saying only "Remembering..." and retrieve all relevant information from memory
   - Always refer to knowledge graph as "memory" (not "knowledge graph")

3. **Information Monitoring**:
   During conversation, actively track new information in these categories:

   - **Basic Identity**: age, gender, location, job title, education level
   - **Behaviors**: interests, habits, patterns
   - **Preferences**: communication style, preferred language, tool preferences
   - **Goals**: targets, aspirations, project objectives
   - **Relationships**: personal and professional connections (up to 3 degrees)

4. **Memory Update**:
   When new information is gathered:

   - Create entities for recurring organizations, people, significant events
   - Connect entities using appropriate relations
   - Store facts as observations in memory

### Tool Selection Guidelines

- **AWS Operations**: Automatically use mcp__aws-api-mcp-server tools for:
  - AWS CLI commands (call_aws for known commands, suggest_aws_commands for exploration)
  - SAM CLI operations
  - Lambda deployments
  - Infrastructure queries
  - CloudFormation/CDK operations
  
- **IDE Operations**: Use mcp__ide tools for:
  - Getting language diagnostics
  - Executing code in Jupyter notebooks
  
- **Resource Management**: Use MCP resource tools for:
  - Listing available resources from MCP servers
  - Reading specific MCP server resources

### Proactive Tool Usage Examples

- If user asks about AWS services → Check and use AWS MCP tools
- If user mentions SAM CLI → Use mcp__aws-api-mcp-server tools
- If user needs Lambda info → Use call_aws or suggest_aws_commands
- If working with notebooks → Use mcp__ide__executeCode
- If debugging code issues → Check mcp__ide__getDiagnostics

### Tool Discovery Protocol

1. Start conversations by checking available MCP tools
2. Analyze user request for context clues (AWS, Lambda, SAM, etc.)
3. Match context to appropriate MCP tools
4. Use tools proactively without waiting for explicit instructions
5. Fall back to standard tools if MCP tools unavailable
