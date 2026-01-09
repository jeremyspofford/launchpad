# Git Multi-Identity Cheatsheet

How to manage multiple Git identities (personal, work, client) with SSH.

## How It Works

SSH config uses host aliases to select different keys:
- `github.com` → Personal key (default)
- `github.com-work` → Work key
- `github.com-personal` → Explicit personal key

## SSH Key Setup

### Generate Keys

```bash
# Personal key
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_personal -C "personal@example.com"

# Work key
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_work -C "work@company.com"
```

### Add Keys to SSH Agent

```bash
# macOS (persists across reboots)
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_personal
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_work

# Linux
ssh-add ~/.ssh/id_ed25519_personal
ssh-add ~/.ssh/id_ed25519_work
```

### Add Public Keys to GitHub/GitLab

Copy public key and add to your account settings:
```bash
pbcopy < ~/.ssh/id_ed25519_personal.pub  # Personal GitHub
pbcopy < ~/.ssh/id_ed25519_work.pub      # Work GitHub
```

## Clone Patterns

### Personal Repository
```bash
# Uses default (personal) key
git clone git@github.com:username/repo.git

# Or explicit
git clone git@github.com-personal:username/repo.git
```

### Work Repository
```bash
# Uses work key
git clone git@github.com-work:org/repo.git
```

## Change Remote for Existing Repo

```bash
# Check current remote
git remote -v

# Change to work identity
git remote set-url origin git@github.com-work:org/repo.git

# Change to personal
git remote set-url origin git@github.com-personal:username/repo.git
```

## Test SSH Connection

```bash
# Test personal
ssh -T git@github.com-personal

# Test work
ssh -T git@github.com-work

# Test default
ssh -T git@github.com
```

## Directory-Based Git Config (Alternative)

Instead of SSH aliases, you can use directory-based config in `~/.gitconfig`:

```ini
# Default (personal)
[user]
    name = "Personal Name"
    email = "personal@example.com"

# Work overrides for ~/work/ directory
[includeIf "gitdir:~/work/"]
    path = ~/.config/git/work.gitconfig
```

Then in `~/.config/git/work.gitconfig`:
```ini
[user]
    name = "Work Name"
    email = "work@company.com"
```

## Quick Reference

| Scenario | Clone Command |
|----------|---------------|
| Personal GitHub | `git clone git@github.com:user/repo.git` |
| Work GitHub | `git clone git@github.com-work:org/repo.git` |
| Personal GitLab | `git clone git@gitlab.com:user/repo.git` |

## Troubleshooting

### Wrong identity being used?
1. Check which key is being used: `ssh -vT git@github.com 2>&1 | grep "Offering"`
2. Verify remote URL: `git remote -v`
3. Check git config: `git config user.email`

### Permission denied?
1. Ensure key is added to agent: `ssh-add -l`
2. Verify public key is added to GitHub/GitLab
3. Test connection: `ssh -T git@github.com`
