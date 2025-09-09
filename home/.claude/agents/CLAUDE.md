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